library geomgraph.test_intersector;
import 'dart:math' as math;

import 'package:collection/wrappers.dart';
import 'package:unittest/unittest.dart';
import 'package:spatially/base/coordinate.dart';
import 'package:spatially/base/line_segment.dart';
import 'package:spatially/base/tuple.dart';
import 'package:spatially/geom/base.dart';
import 'package:spatially/geomgraph2/geometry_graph.dart' as geomgraph;
import 'package:spatially/geomgraph2/intersector.dart';

part 'mock/intersector.dart';

void main() {
  testSimpleIntersector();
  testMonotoneChain();
  testSweeplineIntersector();
}

testSimpleIntersector() {
  group("simple intersector", () {
    GeometryFactory geomFactory = new GeometryFactory();
    EdgeSetIntersector intersector = SIMPLE_EDGE_SET_INTERSECTOR;
    test("closed linestring", () {
      var lstr_closed = geomFactory.fromWkt("LINESTRING(0 0, 10 0, 10 10, 0 10, 0 0)");
      var edge = new MockEdge(0, lstr_closed);
      //All the intersections should be trivial
      expect(intersector([edge]), unorderedEquals([]));
    });
    test("self intersecting linestring", () {
      var self_intersecting = geomFactory.fromWkt(
          "LINESTRING(0 0, 10 0, 0 10, 10 10, 0 0)");
      var edge = new MockEdge(0, self_intersecting);
      var intersections =
           [ new IntersectionInfo(edge, 1, 2 * math.sqrt(5.0),
                                  edge, 3, 2 * math.sqrt(5.0),
                                  new Coordinate(5.0, 5.0),
                                  true, true)
           ];
      expect(intersector([edge], testAll: true), intersections);
    });
    test("Intesections from different segments", () {
      var edge1 = new MockEdge(1, geomFactory.fromWkt("LINESTRING(0 0, 10 10)"));
      var edge2 = new MockEdge(2, geomFactory.fromWkt("LINESTRING(10 0, 0 10)"));
      var intersections =
          [ new IntersectionInfo(edge1, 0, 2 * math.sqrt(5.0),
                                 edge2, 0, 2 * math.sqrt(5.0),
                                 new Coordinate(5.0, 5.0),
                                 true,true)
          ];
      expect(intersector([edge1, edge2]), unorderedEquals(intersections));
    });
  });
}

testMonotoneChain() {
  group("monotone chain", () {
  GeometryFactory geomFactory = new GeometryFactory();
  test("monotone partition", () {
    MockEdge edge = new MockEdge(0, geomFactory.fromWkt("LINESTRING(0 0, 10 10, 10 15, 20 20, 20 0, 20 -20))"));
    MonotoneChainPartition partition = new MonotoneChainPartition(edge);
    expect(partition.length, equals(2));
    expect(partition.first, equals([new Coordinate(0.0, 0.0),
                                    new Coordinate(10.0, 10.0),
                                    new Coordinate(10.0, 15.0),
                                    new Coordinate(20.0, 20.0)])
                         , reason: "first partition element does not match");
    expect(partition.last, equals([ new Coordinate(20.0, 20.0),
                                    new Coordinate(20.0, 0.0),
                                    new Coordinate(20.0, -20.0)])
                         , reason: "last partition element does not match");
  });
  });
}

testSweeplineIntersector() {
  test("sweep line intersector", () {
  GeometryFactory geomFactory = new GeometryFactory();
  EdgeSetIntersector intersector = MONOTONE_CHAIN_SWEEP_LINE_INTERSECTOR;
  test("closed linestring", () {
    var lstr_closed = geomFactory.fromWkt("LINESTRING(0 0, 10 0, 10 10, 0 10, 0 0)");
    var edge = new MockEdge(0, lstr_closed);
    //All the intersections should be trivial
    expect(intersector([edge]), unorderedEquals([]));
  });
  test("self intersecting linestring", () {
    var self_intersecting = geomFactory.fromWkt(
        "LINESTRING(0 0, 10 0, 0 10, 10 10, 0 0)");
    var edge = new MockEdge(0, self_intersecting);
    var intersections =
         [ new IntersectionInfo(edge, 1, 2 * math.sqrt(5.0),
                                edge, 3, 2 * math.sqrt(5.0),
                                new Coordinate(5.0, 5.0),
                                true, true)
         ];
    expect(intersector([edge], testAll: true), equals(intersections));
  });
  test("Intesections from different segments", () {
    var edge1 = new MockEdge(1, geomFactory.fromWkt("LINESTRING(0 0, 10 10)"));
    var edge2 = new MockEdge(2, geomFactory.fromWkt("LINESTRING(10 0, 0 10)"));
    var intersections =
        [ new IntersectionInfo(edge1, 0, 2 * math.sqrt(5.0),
                               edge2, 0, 2 * math.sqrt(5.0),
                               new Coordinate(5.0, 5.0),
                               true,true)
        ];
    expect(intersector([edge1, edge2]), unorderedEquals(intersections));
  });
  test("long chains", () {
    var edge1 = new MockEdge(1, geomFactory.fromWkt(
        "LINESTRING(0 0, 10 0, 20 5, 30 10, 40 20, 40 30, 40 40, 30 30, 30 20, 10 10, 0 0)"));
    var edge2 = new MockEdge(2, geomFactory.fromWkt(
        "LINESTRING(0 0, 0 10, 5 20, 10 30, 20 40, 30 40, 40 40, 30 30, 20 30, 10 10, 0 0)"));
    var edge3 = new MockEdge(3, geomFactory.fromWkt(
        "LINESTRING(20 0, 20 40)"));
    expect(intersector([edge1,edge2, edge3]).length, 21);
  });
  });
}

