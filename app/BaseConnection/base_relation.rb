# Information a relation should have:
# table information
# klass information
# whether it has been loaded
# official signature:
# ::new(klass, table: klass.arel_table, predicate_builder: klass.predicate_builder, values: {})

require_relative "Modules/searchable"

class BaseRelation
  attr_reader :loaded, :klass, :values, :table

  include Enumerable
  include Modules::Searchable

  def initialize(klass, table: klass.table, db: klass.db, query: nil, values: [])
    @klass = klass
    @db = db
    @table = table
    @query = query
    @values = values
    @loaded = false
  end

  def query
    @query
  end

  def base_query
    @query.query
  end

  def each
    raise "expecting block" unless block_given?
    
    load unless loaded
    i = 0
    while i < @values.length
      yield @values[i]
      i += 1
    end
  end

  def [](n)
    load unless loaded
    @values[n]
  end
  
  def relate(relation)
    raise "expected #{relation} to be a BaseRelation" unless relation.is_a?(BaseRelation)
    @query.compose!(relation.query)
    
    # ensure we reload after we've been related
    @loaded = false
    self
  end
  
  def load
    begin
      unless @query.to_sql == ""
        puts "queried: #{@query.to_sql}"
        @values = @db.instance.execute @query.to_sql 
      end
    rescue => exception
      puts exception.message
      @errors = exception.message
      @query = SastMan.new("")
    end

    @loaded = true
    self.konstruct
  end

  def konstruct
    @konstructed = @values.empty? ? 
      self :
      @values.map! { |val| @klass.new(val) }
  end

  def inspect
    case @loaded
    when false
      self.load
    when true
      @konstructed
    end
  end
end