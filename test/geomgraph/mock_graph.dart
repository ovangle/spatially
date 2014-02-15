/**
 * A mock graph suitable for testing intersectors
 */
library spatially.geomgraph.mock_graph;

import 'package:collection/collection.dart';

import 'package:spatially/spatially.dart';
import 'package:spatially/base/tuple.dart';
import 'package:spatially/geomgraph/geometry_graph.dart' as geomgraph;

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

  bool operator ==(Object other) =>
      other is MockGraph;
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


class MockEdge implements geomgraph.Edge {
  int edgeIdx;
  Linestring lstr;
  MockGraph graph;

  List<Coordinate> get coordinates => new List.from(lstr.coordinates, growable: false);

  MockEdge(int this.edgeIdx, this.lstr) {
    graph = new MockGraph(this);
  }

  toString() => "Edge($edgeIdx)";

  void noSuchMethod(Invocation invocation) {
    throwNoSuchMethod(this, invocation);
  }
}