class Nodes::SubQueryNode < QueryNode
  def to_sql
    "(#{@value.to_sql})"
  end
end