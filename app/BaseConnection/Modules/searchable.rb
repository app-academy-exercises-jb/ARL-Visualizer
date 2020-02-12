module Searchable
  def self.extended(child)
    db = child.db
    table_name = child.table.name
    table_info = child.table.params
    # in this loop, we create a new accessor and find_by_? for each defined attribute
    table_info.each { |k,v|
      key = k.to_s
      method = ("find_by_" + k.to_s).to_sym
      
      # we execute inside our generated class's singleton class in order to make the 'find_by_?' methods class methods. these will be eager loading methods, so they do not return a relation
      child.singleton_class.class_exec(db,key,table_name,method) {
        define_method method do |val|
          query = SastMan.new("SELECT #{@table.name}.* FROM #{table_name} WHERE #{key}='#{val}'")
          klass.new(@db.instance.execute(query.to_sql)[0])
        end
        define_method :klass do; self; end
      }
      # define an accessor for every attribute, for instances of the class
      child.class_exec(k) { attr_accessor k }
    }
  end
  
  def all
    query = SastMan.new("SELECT #{@table.name}.* FROM #{@table.name}")
    return_relation(query)
  end
  
  def find_by(attribs)
    where(attribs).first
  end
  
  def where(attribs)
    unless attribs.is_a?(Hash) || attribs.is_a?(String)
      raise ArgumentError.new("expecting a hash or a string")
    end
    
    if attribs.is_a?(Hash)
      # gotta check these attribs to make sure they exist in klass.table as a column
      # if not poison the query
      attribs = attribs.map { |k,v| "#{k} = '#{v}'" }.join(" AND ") 
    end
    
    query = SastMan.new("WHERE #{attribs}")
    
    return_relation(query)
  end
  
  # returns values, not a relation
  def first(n=1)
    return values[0] if self.class == BaseRelation && loaded && n == 1
    result = limit(n).load
    result.length == 1 ? result[0] : result
  end

  def select(*attribs)
    unless attribs.all? { |atr| atr.is_a?(Symbol) || atr.is_a?(String) }
      raise ArgumentError.new("expecting strings and symbols only")
    end
    
    query = SastMan.new("SELECT #{attribs.join(",")}")

    if self.class == BaseRelation && @query.default_core == true
      raise "unexpected relation" if base_query.type != :select
      base_query.value = query.query.value
      @query.default_core = false
      return self
    end

    return_relation(query)
  end

  def limit(n)
    raise ArgumentError.new("must be integer") unless n.is_a?(Numeric)
    query = SastMan.new("LIMIT #{n}")
    return_relation(query)
  end

  def joins(*joined)
    unless joined.all? { |j| [Symbol, String, Hash].any? { |k| j.is_a?(k) } }
      raise ArgumentError.new("must be symbol, string, or hash")
    end

    query = "FROM #{klass.table.name}"

    associated = Hash.new { |h,k| h[k] = false }
    bad_association = false

    joined.each do |join|
      break if bad_association
      case join
      when String
        query += join
      when Symbol
        if klass.associations.has_key?(join) && associated[join] == false
          assoc = klass.associations[join]
          query += " JOIN #{assoc[:table]} ON #{assoc[:table]}.#{assoc[:fk]} = #{klass.table.name}.#{assoc[:pk]} "
          associated[join] = true
        elsif !klass.associations.has_key?(join)
          bad_association = true
        end
      when Hash
        raise NotImplementedError.new("nested association not yet supported")
      end
    end

    query = "" if bad_association

    query = SastMan.new(query)
    return_relation(query)
  end
  # def order_by
  # def group_by
  # def having
  
  private
  def return_relation(query)
    query.ensure_core(table) if self.class == Class
    relation = BaseRelation.new(klass, query: query)
    return relation if self.class == Class
    self.relate(relation)
  end
end


__END__

reset
require_relative 'base_connection'
BaseConnection.connect('questions.db')
class Question 
  belongs_to :author, class_name: "User"
  has_many :replies
  # has_many :likers, through: :question_likes
  has_many :followers, class_name: "QuestionFollow"
end
class User
  has_many :questions, foreign_key: "author_id"
  has_many :replies
  # has_many :followed_questions, through: :question_follows
  # has_many :liked_questions, through: :question_likes
end
class QuestionLike
  belongs_to :user, class_name: "User", foreign_key: "liker_id"
  belongs_to :question
end
class Reply
  # has_one :parent, class_name: "Reply", foreign_key: "parent_reply_id", optional: true
  belongs_to :author, class_name: "User", foreign_key: "user_id"
  belongs_to :question
end
class QuestionFollow
  belongs_to :follower, class_name: "User"
  belongs_to :question
end