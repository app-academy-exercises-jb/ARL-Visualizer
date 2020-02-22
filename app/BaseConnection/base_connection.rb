# require 'byebug'
# require 'singleton'
# require 'sqlite3'
# require 'active_support/inflector'

# require_relative 'base_object'
# require_relative 'base_table'
# require_relative "base_relation"
require_relative 'Modules/associatable'
require_relative 'Modules/validator'
require_relative 'Modules/equalizer'
require_relative 'Modules/searchable'
# require_relative "SastMan/SastMan"

module BaseConnection
  class << self
    attr_accessor :loaded
    attr_reader :classes

    def connect()
      # connection = 'app/BaseConnection/questions.db'
      # raise "#{connection} not a valid file name" unless File.exist?(connection)
      @loaded = false
      @db = _connect()
      classes = discover_tables(@db)    
      generate_classes!(@db, classes)
    end

    private
    def _connect()
      Class.new do
        include Singleton

        define_method :initialize do
          @conn = PG.connect dbname: ENV['DATABASE_URL']
        end

        define_method :execute do |input|
          @conn.exec(input) do |res|
            results = []
            res.each do |row|
              results << row
            end
            results
          end
        end
      end
    end

    def discover_tables(db)
      tables = []
      query = <<-SQL
        SELECT * 
        FROM pg_catalog.pg_tables 
        WHERE schemaname != 'pg_catalog' 
          AND schemaname != 'information_schema'
          AND tablename != 'schema_migrations'
          AND tablename != 'ar_internal_metadata'
      SQL
      db.instance.execute(query).each { |table|
        tables << table['tablename']
      }
      tables
    end

    def generate_classes!(db, tables)
      @classes = []

      tables.each { |table_name|        
        query = "
          SELECT *
          FROM information_schema.COLUMNS
          WHERE TABLE_NAME = '#{table_name}'"

        table = BaseTable.new(table_name, *db.instance.execute(query))
        
        klass = Object.const_set(table_name.classify, Class.new(BaseObject) {
          self.instance_variable_set(:@db, db)
          self.instance_variable_set(:@table, table)

          def self.db; @db; end
          def self.table; @table; end
          attr_reader :db, :table

          extend Modules::Associatable
          extend Modules::Validator
          extend Modules::Searchable
          include Modules::Equalizer
        })

        @classes << table_name.classify
      }

      @db = nil
      @loaded = true
      @classes
    end
  end
end