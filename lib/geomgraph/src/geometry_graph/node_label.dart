part of spatially.geomgraph.geometry_graph;

class Node implements GraphNodeLabel<Node> {
  final GeometryGraph graph;
  final Coordinate coordinate;
  final Tuple<Location,Location> locations;

  Node._(this.graph, this.coordinate, this.locations);

  bool operator ==(Object other) =>
      other is Node && other.coordinate == coordinate;

  int get hashCode => coordinate.hashCode;

  String toString() => "node: $coordinate";

}