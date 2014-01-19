part of spatially.geomgraph.geometry_graph;

class Node extends graph.GraphNode<Coordinate> {
  NodeLabel get label => super.label;

  Coordinate get coordinate => label.coordinate;

  Node(GeometryGraph g, NodeLabel label) :
    super(g, label);

  String toString() => "Node($coordinate)";
}

class NodeLabel extends GeometryLabelBase<Coordinate> {
  final Coordinate coordinate;

  NodeLabel(this.coordinate, Tuple<Location,Location> locationDatas) :
    super(locationDatas);

  factory NodeLabel.fromEdgeLabel(Coordinate c, GeometryLabelBase label) {
    var locations =
        new Tuple(new Location.fromLocation(label.locationDatas.$1, asNodal: true),
                  new Location.fromLocation(label.locationDatas.$2, asNodal: true));
    return new NodeLabel(c, locations);
  }

  bool operator ==(Object other) =>
      other is NodeLabel
      && other.coordinate == coordinate;

  int get hashCode => coordinate.hashCode;

}


