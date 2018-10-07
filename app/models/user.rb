class User
  include Neo4j::ActiveNode

  property :name, type: String
  property :ip, type: String

  has_many :both, :friends, type: :FRIENDSHIP, model_class: :User

  def geolocate_ip
    geolite_file = File.join(Rails.root, 'app', 'assets', 'GeoLite2', 'GeoLite2-City.mmdb')
    db = MaxMindDB.new(geolite_file)
    ret = db.lookup( ip )
    [ret.location.latitude , ret.location.longitude]
  end
end
