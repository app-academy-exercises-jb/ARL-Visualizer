class BaseTable
  attr_reader :primary_key, :name, :columns, :params

  def initialize(name, *table_info)
    @name = name
    @params = {}
    @primary_key = []
    @columns = []
    
    table_info.each { |hash|
      name = hash["column_name"]
      @params[name.to_sym] = {
        name: name,
        type: hash["data_type"],
        nullable: (hash["is_nullable"] != "NO"),
        dflt_value: hash["column_default"],
        primary: (hash["ordinal_position"] == "1")
      }
      @columns << name.to_sym
      @primary_key << name.to_sym if hash["pk"] == 1
    }
  end
end