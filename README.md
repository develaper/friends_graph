### 0. Installation

After running bundle install don't forget to run:

```
rake neo4j:install[community-latest]
rake neo4j:start
```




### 1. Friends Of Friends

```
#app/models/user.rb
class User
  include Neo4j::ActiveNode

  property :name, type: String
  property :ip, type: String
  validates :ip , presence: true

  has_many :both, :friends, rel_class: :Friendship, model_class: :User
end

#app/services/friendship_validator_service.rb

class FriendshipValidatorService

  def initializer()
  end

  def one_degree_of_separation?(current_user, target_user)
    check_degrees_of_separation(1, current_user, target_user)
  end

  def two_degrees_of_separation?(current_user, target_user)
    check_degrees_of_separation(2, current_user, target_user)
  end

  def check_degrees_of_separation(degrees = 1, current_user, target_user)
    current_user.friends(rel_length: degrees + 1).where(id:target_user.id).any?
  end
end

```

After evaluating different approaches, I decided to use the neo4j gem to model the relationship between users. This gem allows handling graphs in a very Rails flavored way. Based on the gem's docs it is relatively easy to use with ActiveRecord through configuration and scalable. But also is important to remember that applying this solution to a production environment implies installing the neo4j Server.



### 2. Visiting Friends of Friends

Additionally, store an IP with each user. Write one (or multiple) reusable Ruby service(s) with the following functionality:


I should highlight that my solution only observes the happy path. A validation of the ip before saving would be a task to add to the next iteration. Checking that is a real ip and that it is geolocable.


- take one IP and return the latitude and longitude:

```
#app/services/geolocate_ip_service.rb
class GeolocateIpService

  def geolocate_ip (ip)
    geolite_file = File.join(Rails.root, 'app', 'assets', 'GeoLite2', 'GeoLite2-City.mmdb')
    db = MaxMindDB.new(geolite_file)
    ret = db.lookup( ip )
    [ret.location.latitude , ret.location.longitude]
  end
end

```

Here I used the maxminddb gem that allows to locate an ip without any external API interaction. It allows us to get result without relying on in an external service but could result in a not so accurate geolocation.



- take two IPs and return the haversine distance between the location of the ips:

```
#app/services/distance_calculator_service.rb
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

```

After checking a few possible solutions the gem geocoder seemed the most trustable (and recently maintained one). Although I only used this gem to calculate the haversine distance between the to locations we can switch to this gem if we want to geolocate ips against an external service.




- take two user ids A and B and return a list of user ids. The list of should start with the user id A and end with user id B. The ids in between are a shortest path between A and B. The shortest path is given by a graph in which the users are the nodes, direct friendships are the edges and the  haversine distance is the weight of the edges:

```
#app/services/path_calculator_service.rb
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

```

"Close, but not banana"


In this service I figured out how to get all the paths from one node to another using the Cypher's query style but I couldn't find the right syntax to apply the weights to get the shortest weighted path.
I was trying to apply a query similar to the one in this link:

https://iansrobinson.com/2013/06/24/cypher-calculating-shortest-weighted-path/

```
MATCH   p=(startNode)-[rels:CONNECTED_TO*1..4]->(endNode)
RETURN  p AS shortestPath,
        reduce(weight=0, r in rels : weight+r.weight) AS totalWeight

```
Digging in the docs and resources and googling like crazy I found some clues and tips that seem to point me in the right direction. I know that Cypher has a 'shortestPath' method and also neo4j.rb has a Path class but I didn't have enough time to keep on searching for the best syntactical solution, so I decided to work with what I already had iterating through the collection of paths, calculating each path's weight and displaying the ids of the users in the shortest one.

Of course, I am aware of the growth of the costs in performance related to this solution, but I guess that it's better done than perfect.
