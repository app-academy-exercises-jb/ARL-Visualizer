module Associatable
  def self.extended(child) 
    child.instance_variable_set(:@associations, Hash.new)
    child.singleton_class.class_exec() { define_method :associations do; @associations; end }
  end
  #
  # collective associations generate these methods:
  # #assocs, #assocs=, #assoc_ids
  # 
  # valid options:
  # class_name, primary_key, foreign_key, through, source
  #
  def has_many(assocs, scope=nil, **opts)
    raise ArgumentError.new("First argument must be a symbol") unless assocs.is_a?(Symbol)

    if opts[:through]
      # source = opts[:source] || assocs 
      # klass = Object.const_get(source) 
      
      # foreign_key = opts[:through] 
      
      # self.define_method assocs do 
      #   pk = self.send primary_key.to_sym 
      #   full_context = self.class.table.name.to_s + "." + self.class.table.primary_key.to_s
      #   klass.joins(foreign_key).where("#{full_context} = #{pk}")
      # end

    else
      # debugger
      table = opts[:class_name] || assocs.to_s.classify 
      klass = Object.const_get(table)
      primary_key = opts[:primary_key] || "id"
      foreign_key = opts[:foreign_key] || self.to_s.singularize.downcase + "_id"  #
      
      self.define_method assocs do
        pk = self.send primary_key.to_sym
        klass.where(foreign_key.to_sym => pk)
      end

      @associations[assocs] = {pk: primary_key, fk: foreign_key, table: klass.table.name}
    end

    self
  end



  # singular associations generate these methods:
  # #assoc, #assoc=
  # 
  # valid opts:
  # class_name, primary_key, foreign_key, through, source
  # 
  def has_one(assoc, scope=nil, **opts)
  end

  #
  # valid opts:
  # class_name, primary_key, foreign_key
  #
  def belongs_to(assoc, scope=nil, **opts)
    table = opts[:class_name] || assoc.to_s.classify
    klass = Object.const_get(table)
    primary_key = opts[:primary_key] || "id" 
    foreign_key = opts[:foreign_key] || assoc.to_s + "_id"

    
    self.define_method assoc do
      debugger
      fk = self.send foreign_key.to_sym
      klass.find_by(primary_key.to_sym => fk)
    end

    self.define_method (assoc.to_s + "=").to_sym do |assoc_model|
      raise "fatal" unless assoc_model.class == klass
      pk = assoc_model.send primary_key.to_sym
      self.send (foreign_key + "=").to_sym, pk
    end

    @associations[assoc] = {pk: foreign_key, fk: primary_key, table: klass.table.name}
    self
  end
end
