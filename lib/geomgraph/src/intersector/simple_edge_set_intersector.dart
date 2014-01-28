part of spatially.geomgraph.intersector;

/**
 * Find all intersections in a set of edges
 * using the straightforward method of comparing
 * all segments
 */
Set<IntersectionInfo> _simpleEdgeSetIntersector(
      List<Edge> edges,
    { bool testAll: true }) {
  int nOverlaps = 0;
  Set<IntersectionInfo> infos = new Set();
  for (var e1 in edges) {
    for (var e2 in edges) {
      if (testAll || e1 != e2) {
        infos.addAll(_simpleIntersect(e1, e2));
      }
    }
  }
  return infos;
}

Set<IntersectionInfo> _simpleIntersect(Edge e1, Edge e2) {
  Set<IntersectionInfo> infos = new Set();
  for (var i in range(coordinateSegments(e1.coordinates).length)) {
    for (var j in range(coordinateSegments(e2.coordinates).length)) {
      _getIntersectionInfo(e1, i, e2, j).ifPresent(infos.add);
    }
  }
  return infos;
}