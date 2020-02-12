class SastMan
  module Lexer
    QUERIES = %w(select from where limit)
    MODIFIERS = %w(distinct as)
    OPERATORS = %w(on between like in and or join)

    def tokenize(query)
      tokens = []

      current_token = ""
      current_token_type = :word

      change_token = -> (token, type) { 
        if QUERIES.include?(token.downcase) 
          type = :reserved 
        elsif MODIFIERS.include?(token.downcase) 
          type = :modifier
        elsif OPERATORS.include?(token.downcase)
          type = :operator
        elsif type == :nil
          type = :value
        end
        token = token.downcase unless type == :value || type == :word
        # debugger
        tokens << Token.new(type, token) unless token == ""
        current_token = ""
      }

      inter_token = -> (token,type) {
        # periods and commas may sometimes be attached to a word
        change_token.call(current_token[0..-2], current_token_type)
        current_token_type = type
        change_token.call(token, current_token_type)
      }

      query.each_char.with_index { |chr,idx| 
        if current_token_type == :value 
          current_token += chr
        else
          unless /\s/ === chr 
            current_token += chr
          end
        end


        if /(\w|\.|\*)/ === chr
          # we are in the middle of(inclusive) a word
          # but preserve :value type
          current_token_type = :word unless current_token_type == :value
        elsif /'/ === chr
          # we're starting or stopping reading a value
          if current_token_type == :value
            current_token_type = :nil
          else
            current_token_type = :value
          end
        elsif /(>=|<=|<|>|=|\+|\*|\/|-)/ === chr
          # we found an operator token
          current_token_type = :operator
        elsif /,/ === chr
          inter_token.call(",", :comma)
        elsif /\(/ === chr || /\)/ === chr
          inter_token.call(chr, :paren)
        elsif /\)/ === chr
          # current_token_type = :paren
          # change_token.call(current_token,current_token_type)
        elsif /\s/ === chr
          # we finished reading a token, unless we're in the middle of a value literal

          change_token.call(current_token, current_token_type) unless current_token_type == :value
        else
          raise "fatal. unrecognized character #{chr}"
        end
      }

      change_token.call(current_token, current_token_type) unless current_token.empty?
      tokens
    end

    class Token
      attr_reader :type, :value
      def initialize(type, value)
        @type, @value = type, value
      end
      def to_s
        value
      end
      def ==(val)
        value == val
      end
    end

    const_set :NullToken, Token.new(:null, nil)
  end
end

__END__
# test sql:
SELECT users.* FROM users WHERE lname = 'Miller'
SELECT users.* FROM users WHERE id = (SELECT id FROM users WHERE fname = 'Jorge')


"SELECT users.*,questions.* FROM users JOIN questions ON questions.author_id = users.id WHERE lname = 'Miller' AND fname IN (SELECT users.fname FROM users WHERE id > 3)"
# list of tokens we will find:
SELECT
FROM
JOIN
WHERE
AND
ON
names
=
(
)
*
'
,
.