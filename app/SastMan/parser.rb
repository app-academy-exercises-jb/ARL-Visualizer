# 
# This parser is intended to work with a certain subset of SQLite SELECT statements. 
# This is that subset. <Bracketed expressions> are optional. Subqueries must be named with AS:
# 
# SELECT
#   <DISTINCT>
#   table.column, ...,
# FROM
#   (table,subquery), ...,
#   <JOIN>
#     (table,subquery) ON expr(table.column = table.column)
#   <...>
# <WHERE>
#   expr(operators: <,<=,>,>=,!=,=,IN,BETWEEN,LIKE,AND; operands: table.column, subquery)
# <LIMIT>
#   value
# 
# We observe the syntactic rules set out here: https://www.sqlite.org/lang_select.html
# 

# 
# TODO: 
# catch syntax errors and call them out as such, instead of just erroring out
# the entire parser can be rewritten in TDOP style w/ careful control of the precedence vals
# 

# require "byebug"
module Parser
    PRECEDENCE = {
      nil => -1,
      "join" => 0, 
      "on" => 1,
      "or" => 1,
      "and" => 2,
      "like" => 3,
      "in" => 3,
      "!=" => 3,
      "=" => 3,
      ">=" => 4,
      ">" => 4,
      "<=" => 4,
      "<" => 4,
      "-" => 5,
      "+" => 5,
      "/" => 6,
      "*" => 6
    }
    def generate_tree(tokens)
      count = -1
      current_token = nil;

      counter = ->() { count += 1; current_token = tokens[count] }

      # 
      gather_values = ->(tokens, prc) {
        values = []
        current_val = [tokens[0]]
        tokens[1..-1].each { |token|
          prc.call(token) ?
            (values << current_val; current_val = [token]) :
            current_val << token
        }
        values << current_val
        values.map! { |val| self.generate_tree(val) }
      }

      comp_ops = ->(opers, opans, tok) {
        if PRECEDENCE[tok.value] > PRECEDENCE[opers[-1].value]
          opers << tok
        else
          new_operand = self.generate_tree([opers.pop, opans.pop, opans.pop])
          opans << new_operand
          opers << tok
        end
      }

      parse_operators = ->(tokens) { #shunting yard
        operators = [Lexer::NullToken]
        operands = []

        paren_count = 0
        subquery = []
        
        tokens.each { |tok| 
          if paren_count > 0
            subquery << tok
            if tok.value == ")"
              paren_count -= 1
              operands << self.generate_tree(subquery) if paren_count == 0
            elsif tok.value == "("
              paren_count += 1
            end
          else
            if tok.type == :operator
              comp_ops.call(operators, operands, tok)
            elsif tok.value == "("
              paren_count += 1
              subquery << tok
            else
              operands << tok
            end
          end
        }

        until operators.length == 2
          new_operand = self.generate_tree([operators.pop, operands.pop, operands.pop])
          operands << new_operand
        end

        self.generate_tree([operators.pop, operands.pop, operands.pop])

      }

      walk = ->() {
        counter.call
        options = Hash.new { |h,k| h[k.type] = k}
        # debugger
        case current_token.type
        when :reserved
          node_tokens = []
          type = current_token.value.downcase.to_sym
          
          # 
          # In the following two loops, we gather all of the tokens which will define the node which walk.call will return.
          # 
          
          counter.call
          until current_token == nil || current_token.type == :reserved
            node_tokens << current_token
            counter.call
          end
          
          # we've detected a subquery
          if node_tokens[-1].value == "("
            depth = 1
            until current_token.value == ")" && depth == 1
              # depth += 1 if current_token.value == "("
              # depth -= 1 if current_token.value == ")"
              node_tokens << current_token
              counter.call
            end
            node_tokens << current_token
            # FROM must name subqueries, WHERE need not
            2.times { counter.call; node_tokens << current_token} unless type == :where
            raise SyntaxError.new("subquery must be named") if node_tokens[-1].nil?
          end
          
          # debugger
          case type
          when :select
            # we've got a SELECT, which may have a DISTINCT, options, and several selected values
            raise SyntaxError.new("expecting values for SELECT statement") if node_tokens.empty?

            value = node_tokens[0].value == "distinct" ?
              (options[:distinct] = true; self.generate_tree(node_tokens[1..-1])) :
              gather_values.call(node_tokens, ->(t) { t.type == :comma })

            until count >= tokens.length - 1
              count -= 1
              options[walk.call]
            end
          when :from
            # we've got a FROM, which may have multiple tables, subqueries, and JOINs
            tables = []
            joins = []
            has_joins = false
            
            node_tokens.each { |token|
              has_joins = true if !has_joins && token.value == "join"
              has_joins ? 
              joins << token :
              tables << token
            }
            
            raise SyntaxError.new("must select FROM a table or subquery") if tables.empty?
            value = gather_values.call(tables, ->(t) { t.type == :comma })
            value << gather_values.call(joins, ->(j) { j.value == "join" }) if joins.any?
          when :where, :limit
            # we've got a WHERE which has a series of operators and operands 
            value = self.generate_tree(node_tokens)
          end
          
          SastNode.new(type: type, value: value, options: options)
        # we're in a subquery
        when :paren
          subquery_tokens = [current_token]
          options = {}

          debugger
          until current_token.type == :paren && current_token.value == ")"
            counter.call
            subquery_tokens << current_token
          end

          # the subquery may be named:
          if tokens[count+1]&.type == :modifier
            options = {alias: self.generate_tree([tokens[count+2]]) }
          end        

          value = self.generate_tree(subquery_tokens[1..-2])
          
          SastNode.new(type: :query, value: value, options: options)
        when :word, :value
          if tokens[count+1]&.type == :operator
            
            parse_operators.call(tokens)
          else
            type = current_token.type == :word ? :name : :value
            SastNode.new(type: type, value: current_token.value)
          end
        when :comma, :modifier
          self.generate_tree(tokens[1..-1])
        when :operator
          # we assume every operator to be binary, except :join, which is unary
          if tokens[0].value.downcase == "join" 
            operand = self.generate_tree(tokens[1..-1])
            SastNode.new(type: :join, value: operand)
          else
            left = tokens[1].is_a?(SastNode) ? tokens[1] : self.generate_tree([tokens[1]])
            right = tokens[2].is_a?(SastNode) ? tokens[2] :  self.generate_tree([tokens[2]])
            # shunting yard flips our operands. though 'equivalent', we flip them back for ease of inspecting
            SastNode.new(type: :operator, value: [right, left], options: {operator: current_token.value})
          end
        end
      }
      
      return if tokens.empty?
      walk.call
    end
end