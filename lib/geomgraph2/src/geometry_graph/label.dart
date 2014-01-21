part of spatially.geomgraph.geometry_graph;


class EdgeLabel extends GeometryLabelBase<List<Coordinate>> {
  List<Coordinate> coordinates;

  EdgeLabel(List<Coordinate> this.coordinates,
            Tuple<Location,Location> locationDatas) :
    super(locationDatas);

  /**
   * Creates a new [EdgeLabel] from the location datas on the given label
   * but with the coordinates given by [:coords:].
   */
  factory EdgeLabel.fromLabel(List<Coordinate> coords, EdgeLabel label) {
    var locations = new Tuple(
         new Location.fromLocation(label.locationDatas.$1, asNodal: false),
         new Location.fromLocation(label.locationDatas.$2, asNodal: false));
    return new EdgeLabel(coords, locations);
  }

  void mergeWith(EdgeLabel label) {
    this.locationDatas.$1.mergeWith(label.locationDatas.$1);
    this.locationDatas.$2.mergeWith(label.locationDatas.$2);
  }

  bool operator ==(Object other) =>
      other is EdgeLabel && _listEq.equals(coordinates, other.coordinates);

  int get hashCode => _listEq.hash(coordinates);

  String toString() => "EdgeLabel($coordinates, $locationDatas)";
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

class GeometryLabelBase<T> extends graph.Label<T> {
  /**
   * The location datas on the label. The first location data
   * refers to the location data of the first geometry of the graph,
   * the second to the second geometry of the graph.
   */
  final Tuple<Location,Location> locationDatas;

  GeometryLabelBase(Tuple<Location,Location> this.locationDatas);

  /**
   * Edges have one location undetermined during initialization.
   * This retrieves it. If both locations are determined, or neither
   * location is, throws a [StateError]
   */
  int get _knownLocationIdx {
    if (locationDatas.$1.isKnown) {
      if (locationDatas.$2.isKnown)
        throw new StateError("No locations known");
      return 1;
    } else if (locationDatas.$2.isKnown) {
      return 2;
    } else {
      throw new StateError("Both locations known");
    }
  }
}
