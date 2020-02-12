class BaseTable
  attr_reader :primary_key, :name, :columns, :params

  def initialize(name, *table_info)
    @name = name
    @params = {}
    @primary_key = []
    @columns = []
    
    table_info.each { |hash|
      name = hash["name"]
      @params[name.to_sym] = {
        name: name,
        type: hash["type"],
        nullable: (hash["notnull"] != 1),
        dflt_value: hash["dflt_value"],
        primary: (hash["pk"] == 1)
      }
      @columns << name.to_sym
      @primary_key << name.to_sym if hash["pk"] == 1
    }
  end
end