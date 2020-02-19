# require_relative "../Modules/equalizer.rb"

class SastNode
  include Modules::Equalizer

  attr_reader :options
  attr_accessor :value
  
  def self.new(type:, value: nil, options:{})
    # debugger
    return super unless self == SastNode
    case type
    when :select, :where, :join, :from, :limit
      Nodes::QueryNode.new(type: type, value: value, options: options)
    # when :from
    #   FromNode.new(type: type, value: value, options: options)
    when :name, :value
      Nodes::ConstNode.new(type: type, value: value, options: options)
    when :operator
      Nodes::OperNode.new(type: type, value: value, options: options)
    when :query
      Nodes::SubQueryNode.new(type: type, value: value, options: options)
    else
      raise "unknown type: #{type || "undefined"}"
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