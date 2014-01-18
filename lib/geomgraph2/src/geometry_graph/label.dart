part of spatially.geomgraph.geometry_graph;

class GeometryLabelBase<T> extends graph.Label<T> {
  /**
   * The location datas on the label. The first location data
   * refers to the location data of the first geometry of the graph,
   * the second to the second geometry of the graph.
   */
  final Tuple<Location,Location> locationDatas;

  GeometryLabelBase(Tuple<Location,Location> this.locationDatas);
}
