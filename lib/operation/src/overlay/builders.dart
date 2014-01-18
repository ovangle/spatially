part of operation.overlay;

List<Polygon> buildPolygons(GeometryFactory geomFactory, 
                            PlanarGraph graph, 
                            int overlayType) {
  List<Ring> edgeRings = buildMaximalEdgeRings(geomFactory, graph);
}

List<Ring> buildMaximalEdgeRings(GeometryFactory geomFactory, PlanarGraph graph) {
  List<Ring> edgeRings = new List<Ring>();
  
}