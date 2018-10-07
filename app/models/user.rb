class User
  include Neo4j::ActiveNode

  property :name, type: String
  property :ip, type: String

  has_many :both, :friends, type: :FRIENDSHIP, model_class: :User

  def self.one_degree_of_separation?(current_user, target_user)
    check_degrees_of_separation(1, current_user, target_user)
  end

  def self.two_degrees_of_separation?(current_user, target_user)
    check_degrees_of_separation(2, current_user, target_user)
  end

  def self.check_degrees_of_separation(degrees = 1, current_user, target_user)
    current_user.friends(rel_length: degrees + 1).where(id:target_user.id).any?
  end

  def geolocate_ip
    geolite_file = File.join(Rails.root, 'app', 'assets', 'GeoLite2', 'GeoLite2-City.mmdb')
    db = MaxMindDB.new(geolite_file)
    ret = db.lookup( ip )
    [ret.location.latitude , ret.location.longitude]
  end
end
