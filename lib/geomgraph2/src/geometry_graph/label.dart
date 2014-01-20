part of spatially.geomgraph.geometry_graph;

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
