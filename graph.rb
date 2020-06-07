include Marshal
class Graph
  attr_reader :edges, :nodes

  def initialize(nodes, edges)
    @nodes = nodes
    @edges = edges
  end

  def dup
    Marshal.load(Marshal.dump(self))
  end

  def max_match
    m = []
    until @edges.empty?
      n, e =  @edges.first
      remove_node(n)
      unless e.empty?
        m << [n, e[0]]
        remove_node e[0]
      end
    end
    m
  end

  def vertex_cover
    c = []
    while has_edges?
      n = nodes_by_degree.first
      c << n unless @edges[n].empty?
      remove_node(n)
    end
    c
  end

  def has_edges?
    return false if @edges.empty?
    @edges.values.any?{|e| !e.empty?}
  end

  def remove_node(node)
    @edges.values.map!{|edge| edge.delete(node)}
    @edges.delete(node)
    @nodes.delete(node)
  end

  def nodes_by_degree
    @nodes.sort_by{|n| -@edges[n].length}
  end
end