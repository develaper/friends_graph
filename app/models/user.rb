class User
  include Neo4j::ActiveNode

  property :name, type: String
  property :ip, type: String

  has_many :both, :friends, rel_class: :Friendship, model_class: :User
end
