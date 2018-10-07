class User
  include Neo4j::ActiveNode
  include Geolocable

  property :name, type: String
  property :ip, type: String

  has_many :both, :friends, type: :FRIENDSHIP, model_class: :User
end
