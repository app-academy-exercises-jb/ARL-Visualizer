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
    def connect(connection)
      raise "#{connection} not a valid file name" unless File.exist?(connection)
      # pry
      
      @db = _connect(connection)
      classes = discover_tables(@db)    
      generate_classes!(@db, classes)
    end

    private
    def _connect(connection)
      Class.new SQLite3::Database do
        include Singleton

        define_method :initialize do
          super connection
          self.type_translation = true
          self.results_as_hash = true
        end
      end
    end

    def discover_tables(db)
      tables = []
      db.instance.execute("SELECT name FROM sqlite_master").each { |table|
        tables << table['name']
      }
      tables
    end

    def generate_classes!(db, tables)
      @classes = []

      tables.each { |table_name|
        next if /^sqlite_/.match?(table_name)
        
        table = BaseTable.new(table_name, *db.instance.execute("PRAGMA table_info(#{table_name})"))
        
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

        @classes << klass
      }

      @db = nil
      @classes
    end
  end
end

BaseConnection.connect('app/BaseConnection/questions.db') if BaseConnection.loaded == false
BaseConnection.loaded = true