require './graph'
class VertexCover

  attr_reader :upper_bound
  attr_accessor :verbose

  def initialize(g, c, initial_upper_bound, verbose = true)
    @upper_bound = initial_upper_bound
    @instances = Queue.new
    @instances << {g: g, c: c, n: 0}
    @counter = 0
    @verbose = verbose
  end

  def calculate_instance
    until @instances.empty?
      tmp = @instances.pop
      g = tmp[:g]
      c = tmp[:c]
      max_match = g.dup.max_match
      local_lower_bound = max_match.length + c.length

      if @verbose
        puts "Calculating Instance: #{tmp[:n]}"
        puts "V = {#{g.nodes.join(', ')}}"
        puts "|C| = #{c.length}, C = {#{c.join(', ')}}"
        puts "|M| = #{max_match.length}, M = {#{max_match.map { |m| '{' + m[0].to_s + ', ' + m[1].to_s + '}' }.join(', ')}}"
        puts "L' = #{max_match.length} + #{c.length} = #{local_lower_bound}"
        puts local_lower_bound < @upper_bound ? "L' < U" : "L' >= U"
      end

      if local_lower_bound < @upper_bound
        vertex_cover = g.dup.vertex_cover
        local_upper_bound = vertex_cover.length + c.length

        if @verbose
          puts "|S| = #{vertex_cover.length}, S = {#{vertex_cover.join(', ')}}"
          puts "U' = #{vertex_cover.length} + #{c.length} = #{local_upper_bound}"
          puts local_upper_bound < @upper_bound ? "U' < U, U = #{local_upper_bound}" :  "U' >= U"
        end

        @upper_bound = local_upper_bound  if local_upper_bound < @upper_bound

        branch(tmp)  if local_lower_bound < @upper_bound
      end
    end
    @upper_bound
  end

  def branch(instance)
    g = instance[:g]
    sorted_edges = g.nodes_by_degree
    largest_degree_node = sorted_edges[0]
    largest_degree_node_neighbours = g.edges.fetch(sorted_edges[0], [])
    g1 = g.dup
    g1.remove_node(largest_degree_node)
    c1 = instance[:c].dup << largest_degree_node

    g2 = g.dup
    g2.remove_node(largest_degree_node)
    largest_degree_node_neighbours.each { |node| g2.remove_node(node) }
    c2 = instance[:c] + largest_degree_node_neighbours

    if @verbose
      puts "L'< U"
      puts 'Branching:'
      puts "Instance #{@counter + 1}: G' = G - {#{largest_degree_node}}, C' = {#{c1.join(', ')}}"
      puts "Instance #{@counter + 2}: G' = G - {#{largest_degree_node}, #{largest_degree_node_neighbours.join(', ')}}, C' = {#{c2.join(', ')}}"
    end

    @counter += 1
    @instances << {c: c1, g: g1, n: @counter}

    @counter += 1
    @instances << {c: c2, g: g2, n: @counter}
  end
end
