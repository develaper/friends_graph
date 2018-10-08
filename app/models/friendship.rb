class Friendship
  include Neo4j::ActiveRel

  before_save :set_weight
  from_class :User
  to_class :User
  type 'FRIENDSHIP'
  property :weight

  def set_weight
    distance_calculator = DistanceCalculatorService.new()
    distance_between_nodes = distance_calculator.haversine_distance(from_node.ip, to_node.ip)
    self.weight = distance_between_nodes
  end
end
