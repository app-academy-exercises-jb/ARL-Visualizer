class Nodes::QueryNode < SastNode
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

  def add_value(val)
    case type
    when :select
      @value << value
    when :from
      @value[-1].is_a?(Array) ? 
        @value.insert(-2, value) :
        @value << value
    when :where
      @value = SastNode.new(type: :operator, value: [@value, val], options: {operator: "and"})
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