class GeolocateIpService

  def geolocate_ip (ip)
    geolite_file = File.join(Rails.root, 'app', 'assets', 'GeoLite2', 'GeoLite2-City.mmdb')
    db = MaxMindDB.new(geolite_file)
    ret = db.lookup( ip )
    [ret.location.latitude , ret.location.longitude]
  end
end
