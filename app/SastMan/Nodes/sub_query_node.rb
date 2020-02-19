class Nodes::SubQueryNode < Nodes::QueryNode
  def to_sql
    "(#{@value.to_sql})"
  end
end