class Nodes::ConstNode < SastNode
  def inspect
    "{:#{@type}=>#{@value}}"
  end
  
  def to_sql
    @value
  end

  def to_i
    Integer(@value)
  end

  def to_s
    "{:#{@type}=>#{@value}}"
  end
end 