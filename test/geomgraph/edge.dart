library test_edge;

import 'package:unittest/unittest.dart';
import 'package:spatially/base/coordinate.dart';
import 'package:spatially/base/line_segment.dart';
import 'package:spatially/geom/base.dart';
import 'package:spatially/geomgraph/edge.dart';
import 'package:spatially/geomgraph/intersector.dart';


void main() {
  group("geomgraph.edge: ", () {
    testSplitEdge();
  });
}

/**
 * Mock edge for testing splitting
 */
class MockSplitEdge extends Edge {
  MockSplitEdge(Linestring lstr) : 
    super(null, null, null, lstr.coordinates);
}

void testSplitEdge() {
  group("split edge: ", () {
    GeometryFactory geomFactory = new GeometryFactory();
    test("single split at coordinate", () {
      var edge = new MockSplitEdge(
          geomFactory.fromWkt("LINESTRING(0 0, 10 10, 10 0, 0 0)"));
      var intersections =
          [ new IntersectionInfo(edge, 1,  0.0,
                                 edge, 1,  0.0,
                                 new Coordinate(10.0, 10.0),
                                 false, false) ];
      var before = [new Coordinate(0.0, 0.0), new Coordinate(10.0, 10.0)];
      var after  = [new Coordinate(10.0, 10.0), new Coordinate(10.0, 0.0), new Coordinate(0.0, 0.0)];
      expect(edge.splitCoordinates(intersections), equals([before, after]));               
    });
    test("multiple splits at coords", () {
      var edge = new MockSplitEdge(
          geomFactory.fromWkt("LINESTRING(0 0, 10 10, 10 0, 0 0)"));
      var intersections =
          [ new IntersectionInfo(edge, 1,  0.0,
                                edge, 1,  0.0,
                                new Coordinate(10.0, 10.0),
                                false, false),
            new IntersectionInfo(edge, 2,  0.0,
                                 edge, 2,  0.0,
                                 new Coordinate(5.0, 0.0),
                                 false, false) ];
      var exp1 = [new Coordinate(0.0, 0.0), new Coordinate(10.0, 10.0)];
      var exp2 = [new Coordinate(10.0, 10.0), new Coordinate(10.0, 0.0), new Coordinate(5.0, 0.0)];
      var exp3  = [new Coordinate(5.0, 0.0), new Coordinate(0.0, 0.0)];
      expect(edge.splitCoordinates(intersections), equals([exp1, exp2, exp3]));               
    });
    test("split at line segment", () {
        var edge = new MockSplitEdge(
            geomFactory.fromWkt("LINESTRING(0 0, 10 10, 10 0, 0 0)"));
        var intersections =
            [ new IntersectionInfo( edge, 1,  0.0,
                                    edge, 1,  0.0,
                                    new LineSegment(new Coordinate(10.0, 10.0), new Coordinate(10.0, 5.0)),
                                    false, false)
            ];
        var exp1 = [new Coordinate(0.0, 0.0), new Coordinate(10.0, 10.0)];
        var exp2 = [new Coordinate(10.0, 10.0), new Coordinate(10.0, 5.0)];
        var exp3  = [new Coordinate(10.0, 5.0), new Coordinate(10.0, 0.0), new Coordinate(0.0, 0.0)];
        expect(edge.splitCoordinates(intersections), equals([exp1, exp2, exp3]));               
     });
  });
}

