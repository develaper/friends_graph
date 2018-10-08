class PathCalculatorService

  def initializer
  end

  def shortest_weighted_path(start_user_id, end_user_id)
    a = User.find(start_user_id)
    b = User.find(end_user_id)

    all_paths = a.query_as(:a).match_nodes(b: b).match('p=((a)-[*]-(b))').pluck(:p)
    paths_and_weights = {}
    all_paths.each_with_index do |path, index|
      total_weight = 0
      path.relationships.each { |relationship| total_weight = total_weight + relationship.properties[:weight] }
      paths_and_weights[index] = total_weight
    end
    paths_and_weights = paths_and_weights.sort_by {|_key, value| value}.to_h
    shortest_path_index = paths_and_weights.keys.first
    shortest_path = all_paths[shortest_path_index]

    nodes_in_path = []
    shortest_path.nodes.each { |node| nodes_in_path << node.properties[:uuid] }
    nodes_in_path
  end
end
