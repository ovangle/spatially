part of geomgraph.test_intersector;

class MockEdge implements geomgraph.Edge {
  int edgeIdx;
  Linestring lstr;
  MockGraph get _graph => new MockGraph(this);

  List<Coordinate> get coordinates => new List.from(lstr.coordinates, growable: false);

  MockEdge(int this.edgeIdx, this.lstr);

  toString() => "Edge($edgeIdx)";

  void noSuchMethod(Invocation invocation) {
    throwNoSuchMethod(this, invocation);
  }
}

class MockGraph implements geomgraph.GeometryGraph {
  Tuple<Geometry,Geometry> get geometries => new Tuple(lstr, null);
  Set<geomgraph.Edge> _edges;
  Set<geomgraph.Node> _boundaryNodes;

  Linestring lstr;
  MockGraph(MockEdge edge) :
    this.lstr = edge.lstr,
    _edges = new Set.from([edge]),
    _boundaryNodes = new Set.from([new MockNode(edge.lstr.startPoint.coordinate),
                                   new MockNode(edge.lstr.endPoint.coordinate)]);

  UnmodifiableSetView<geomgraph.Edge> get edges => new UnmodifiableSetView(_edges);
  Iterable<geomgraph.Node> get boundaryNodes => _boundaryNodes;

  void noSuchMethod(Invocation invocation) {
    throwNoSuchMethod(this, invocation);
  }
}

class MockNode implements geomgraph.Node {
  Coordinate coordinate;

  MockNode(this.coordinate);

  void noSuchMethod(Invocation invocation) {
    throwNoSuchMethod(this, invocation);
  }
}

void throwNoSuchMethod(dynamic receiver, Invocation invocation) {
  throw new NoSuchMethodError(
      receiver,
      invocation.memberName,
      invocation.positionalArguments,
      invocation.namedArguments);
}
