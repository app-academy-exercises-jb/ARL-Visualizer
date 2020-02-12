require_relative "../Modules/equalizer.rb"

class SastMan
  class SastNode
    include Equalizer

    attr_reader :options
    attr_accessor :value
    
    def self.new(type:, value: nil, options:{})
      # debugger
      return super unless self == SastNode
      case type
      when :select, :where, :join, :from, :limit
        QueryNode.new(type: type, value: value, options: options)
      # when :from
      #   FromNode.new(type: type, value: value, options: options)
      when :name, :value
        ConstNode.new(type: type, value: value, options: options)
      when :operator
        OperNode.new(type: type, value: value, options: options)
      when :query
        SubQueryNode.new(type: type, value: value, options: options)
      else
        raise "unknown type: #{type}"
      end

    end

    def initialize(type:, value: nil, options: {})
      @type = type
      @value = value
      @options = options.empty? ? {} : options
    end

    def type
      @type == :operator ?
        options[:operator] :
        @type
    end

    def to_s
      @options.nil? ?
        "{:#{@type}=>#{@value}}" :
        "{:#{@type}=>#{@value},\n#{options.values.join(",\n")}}"
    end

    def inspect
      @options.nil? ? 
        {@type => @value} :
        [{@type => @value}, *options.values].join(",\n")
    end

    def add_value(value)
      raise NotImplementedError.new
    end

    def add_option(option)
      raise NotImplementedError.new
    end
  end


  class OperNode < SastNode
    def inspect
      "{#{@value[0]} #{options[:operator]} #{@value[1].to_s}}"
    end
    

    def to_sql
      "#{@value[0].to_sql} #{options[:operator].upcase} #{@value[1].to_sql}"
    end

    def to_s
      "{#{@value[0]} #{options[:operator]} #{@value[1].to_s}}"
    end
  end

  class ConstNode < SastNode
    def inspect
      "{:#{@type}=>#{@value}}"
    end
    
    def to_sql
      @value
    end

    def to_i
      Integer(@value)
    end

    def to_s
      "{:#{@type}=>#{@value}}"
    end
  end 
  
  class QueryNode < SastNode
    def to_sql
      case type
      when :select
        value = @value.map(&:to_sql).join(", ")
      when :from
        if @value[-1].is_a?(Array)
          value = @value[0..-2].map(&:to_sql).join(", ")
          value += " " + @value[-1].map(&:to_sql).join(" ")
        else
          value = @value.map(&:to_sql).join(", ")
        end
      when :join, :where, :limit
        value = @value.to_sql
      end

      # debugger
      
      options = type == :from ? @options[:join] : @options.values

      "#{@type.upcase} #{value} #{options&.map(&:to_sql)&.join(" ")}".chomp(" ")
    end

    def add_value(value)
      case type
      when :select
        @value << value
      when :from
        @value[-1].is_a?(Array) ? 
          @value.insert(-2, value) :
          @value << value
      else 
        raise NotImplementedError.new
      end
    end

    def add_option(option)
      case type
      when :select
        @options[option]
      else 
        raise NotImplementedError.new
      end
    end
  end

  class SubQueryNode < QueryNode
    def to_sql
      "(#{@value.to_sql})"
    end
  end
end