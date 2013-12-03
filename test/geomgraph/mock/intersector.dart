part of geomgraph.test_intersector;


class MockEdge implements Edge {
  Linestring lstr;
  int edgeNum;
  
  MockEdge(int this.edgeNum, Linestring this.lstr);
  
  PlanarGraph get parentGraph => new MockGraph(lstr);
  set parentGraph(PlanarGraph g) => throw 'NotImplemented';
  
  get label => throw 'NotImplemented';
  set label(l) {
    throw 'NotImplemented';
  }
  
  UnmodifiableListView<Coordinate> get coordinates => new UnmodifiableListView(lstr.coordinates);
  set coordinates(Iterable<Coordinate> cs) => throw 'NotImplemented';
  Iterable<LineSegment> get segments => lstr.segments;
  set segments(Iterable<LineSegment> segs) => throw 'NotImplemented';
  
  bool get isPlanar => throw 'NotImplemented';
  bool get isLinear => throw 'NotImplemented';
  
  DirectedEdge getFromStartNode(Node startNode) {
    throw 'NotImplemented';
  }
  
  DirectedEdge getOppositeNode(Node startNode) {
    throw 'NotImplemented';
  }
  
  bool remove() {
    throw 'NotImplemented';
  }
  
  DirectedEdge get forward => throw 'NotImplemented';
  set forward(DirectedEdge fwd) => throw 'NotImplemented';
  DirectedEdge get backward => throw 'NotImplemented';
  set backward(DirectedEdge bwd) => throw 'NotImplemented';
  
  void setDirectedEdges(DirectedEdge forward, DirectedEdge backward) {
    throw 'NotImplemented';
  }
  
  void addIntersections(Iterable<IntersectionInfo> intersections) {
    throw 'NotImplemented';
  }
  void addIntersection(IntersectionInfo intersection) {
    throw 'NotImplemented';
  }
  toString() => "edge$edgeNum";
  
  Iterable<List<Coordinate>> splitCoordinates(Iterable<IntersectionInfo> intersections) {
    throw 'NotImplemented';
  }
}

class MockGraph extends PlanarGraph {
  Linestring lstr;
  
  MockGraph(Linestring this.lstr) : super();

  Iterable<Node> get boundaryNodes {
    List<Node> boundaryNodes = new List();
    Geometry lstrBoundary = lstr.boundary;
    boundaryNodes.addAll(lstrBoundary.coordinates.map((c) => new MockNode(c)));
    return boundaryNodes;
  }
}

class MockNode extends Node {
  MockNode(Coordinate coordinate) : super(coordinate);
}
