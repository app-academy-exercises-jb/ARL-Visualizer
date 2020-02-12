module Validator
  def opt_parser(opt_hash)
    opt_hash.map { |k,v|
      [k.to_sym, v]
    }.to_h
  end

  def object_validator(opt_hash)
    params = table.params 
    
    nullables = params.values.select { |h| h[:nullable] == true}

    if !opt_hash.has_key?(:id) #this should instead check if the hash is the pk
      raise "wrong number of params" unless opt_hash.length <= params.length - nullables.length
      # right now, we assume that the pk is an id which is nullable in the schema
    else
      raise "wrong num of params" unless opt_hash.length == params.values.length
    end

    params.each { |k,v|
      if !opt_hash.has_key?(k) && v[:nullable] == false
        raise "#{k} must be a parameter of #{@table.name}"
      end
    }

    attrib_validator(opt_hash)
    true
  end

  def attrib_validator(opt_hash)
    params = table.params 

    opt_hash.each { |k,v|
      unless params.has_key?(k) # evidently this is not safe, as table_info can be written all willy nilly. the real problem is that the params can't be in an individual object's instance vars, subject to its control
        raise "#{k} is not a valid column of the table #{@table.name}"
      else
        unless v.class <= object_type(params[k][:type])
          unless v.nil? || params[k][:nullable]
            raise "#{v} is not of valid type: #{params[k][:type]}"
          end
        end
      end
    }
  end

  # def table_validator(table)
  #   debugger
  #   raise "invalid table name #{table.tableize}" unless @table_info.has_key?(table.tableize)
  # end

  def object_type(type)
    # a lot more parsing work is necessary here, given that sqlite3 stores all sorts of
    # numbers in TEXT, and booleans in INTEGER
    case type
    when 'TEXT'
      String
    when 'NUMERIC'
      Numeric
    when 'INTEGER'
      Integer
    when 'REAL'
      Float
    when 'BLOB'
      rasise "pls implement me for type BLOB"
    else
      raise "unknown data type"
    end
  end
end