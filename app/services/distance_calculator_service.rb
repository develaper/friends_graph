class DistanceCalculatorService

  def initializer()
  end

  def haversine_distance(ip1, ip2)
    locate_ip_service = GeolocateIpService.new()
    ip1_coordinates = locate_ip_service.geolocate_ip(ip1)
    ip2_coordinates = locate_ip_service.geolocate_ip(ip2)
    Geocoder::Calculations.distance_between(ip1_coordinates, ip2_coordinates)
  end
end
