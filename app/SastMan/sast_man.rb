# require_relative "lexer"
# require_relative "parser"
# require_relative 'sast_node'

# debugger
class SastMan
  # extend Traverser
  extend Parser
  extend Lexer

  attr_accessor :default_core, :query
  
  def initialize(value=nil)
    @query = self.class.parse(value) unless value.nil?
    @default_core = true;
  end

  def compose!(query)
    raise TypeError.new("we only compose with fellow SastMen") unless query.is_a?(SastMan)
    unless @query.type == :select
      @query, query.query = query.query, @query
      raise RuntimeError.new("we expected to have a core") unless @query.type == :select
    end
    base = query.query
    
    case base.type
    when :select
      @query.add_value(base.value)
      base.options.each { |opt| @query.add_option(opt) }
    when :from, :where, :limit
      self.add_option(base)
    when :join
      @query.options[:from].add_value(base.value)
    else
      raise NotImplementedError.new("#{base.type} not yet implemented")
    end
  end

  def add_option(option)
    @query.options.has_key?(option.type) ?
      @query.options[option.type].add_value(option.value) :
      (@query.options[option.type] = option)
  end
  
  def to_sql
    @query ? @query.to_sql : ""
  end

  def ensure_core(table)
    # check for SELECT and FROM options
    # debugger
    return if @query && @query.type == :select && @query.options.has_key?(:from)
    return unless @query
    generate_core(table)
  end
  
  private
  def self.parse(query)
    tokens = self.tokenize(query)
    ast = self.generate_tree(tokens)
  end

  def generate_core(table)
    # generate generic SELECT x.* FROM x sast as core utilizing table's info
    if @query && @query.type == :select
      @query.options[:from] = self.class.new("from #{table.name}")
      return
    elsif @query && @query.type == :from
      new_query = self.class.new("select #{table.name}.*")
      @default_core = true
    else
      # where, limit, join
      new_query = self.class.new("select #{table.name}.* from #{table.name}")
      @default_core = true
    end

    
    self.compose!(new_query)
  end

  
end

# module SastMan::Traverser
#   def traverse(root)
#     puts root.to_sql
#     root.options&.each { |(key, opt)|
#       # p "key: " + key.to_s
#       # p "opt: " + opt.to_s
#       opt.is_a?(Array) ?
#         opt.each { |o| traverse(o) } :
#         traverse(opt)
#     }
#   end
# end