require_relative "./base_connection.rb"

class ArLite
  def initialize
    BaseConnection.connect('./questions.db')
  end
end
