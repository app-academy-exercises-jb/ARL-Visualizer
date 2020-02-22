class Nodes::OperNode < SastNode
  def inspect
    "{#{@value[0]} #{options[:operator]} #{@value[1].to_s}}"
  end

  def to_sql
    "#{@value[0].to_sql} #{options[:operator].upcase} #{@value[1].to_sql}"
  end

  def to_s
    "{#{@value[0]} #{options[:operator]} #{@value[1].to_s}}"
  end
end