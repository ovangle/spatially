part of spatially.geomgraph.geometry_graph;

class Node extends graph.GraphNode<Coordinate> {

  Coordinate get coordinate => (label as NodeLabel).coordinate;

  Node(GeometryGraph g, NodeLabel label) :
    super(g, label);

  String toString() => "Node($coordinate)";
}

class NodeLabel extends GeometryLabelBase<Coordinate> {
  final Coordinate coordinate;

  NodeLabel(this.coordinate, Tuple<Location,Location> locationDatas) :
    super(locationDatas);

  bool operator ==(Object other) =>
      other is NodeLabel
      && other.coordinate == coordinate;

  int get hashCode => coordinate.hashCode;

}


