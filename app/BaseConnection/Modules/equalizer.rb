module Equalizer
  # we must redefine the #hash and #eql? methods of our custom classes, so that we can correctly do set operations on arrays of them later
  def hash
    vars = {}
    self.instance_variables.each { |var| vars[var] = self.instance_variable_get(var) }
    vars.hash
  end

  def eql?(obj)
    self.hash == obj.hash
  end
end