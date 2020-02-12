class BaseObject
  class << self
    def opt_parser(opts)
      raise NotImplementedError.new("must be implemented by inheriting class")
    end
    def object_validator(object)
      raise NotImplementedError.new("must be implemented by inheriting class")
    end
  end

  def initialize(opt_hash)
    if (opt_hash.class == Array && !opt_hash.empty?)
      opt_hash.each { |hash|
        self.class.new(hash)
      }
    elsif (opt_hash.class == SQLite3::ResultSet::HashWithTypesAndFields ||
        opt_hash.class == Hash)
      parsed = self.class.opt_parser(opt_hash)
      self.class.object_validator(parsed)
      parsed.each { |k,v| self.instance_variable_set("@#{k}", v) }
    else
      raise "fatal: #{opt_hash} is not a SQLite3 hash, a hash, or an array thereof"
    end
  end

  def save
    keys = instance_variables.map { |var| var.to_s[1..-1] }
    values = instance_variables.map { |var| instance_variable_get(var) }
    table_name = self.class.table.name
    
    self.class.object_validator(keys.map(&:to_sym).zip(values).to_h)

    db = self.class.instance_variable_get(:@db)

    if self.id.nil?
      db.instance.execute(<<-SQL)
        INSERT INTO
          #{table_name} (#{keys.join(", ")})
        VALUES
          (\'#{values.join("', '")}\')
      SQL
      
      @id = db.instance.last_insert_row_id
    else 
      raise "#{self} not in database" unless self.class.find_by_id(self.id) == self

      values = instance_variables.map { |var| 
        var.to_s[1..-1] + ' = "' + instance_variable_get(var).to_s + '"' unless var == :@id
      }.select { |value| value != nil }

      db.instance.execute (<<-SQL)
        UPDATE
          #{table_name}
        SET
          #{values.join(", ")}
        WHERE
          id = #{self.id}
      SQL
    end
  end
  alias_method :update, :save
end

