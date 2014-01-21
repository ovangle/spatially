part of spatially.geomgraph.geometry_graph;

class Node extends graph.GraphNode<Coordinate> {
  NodeLabel get label => super.label;

  Coordinate get coordinate => label.coordinate;

  Node(GeometryGraph g, NodeLabel label) :
    super(g, label);

  String toString() => "Node($coordinate)";
}
