/**
 * General purpose tests of geometry graph functionality.
 */

library spatially.geomgraph.geometry_graph.general_test;

import 'package:unittest/unittest.dart';
import 'package:spatially/spatially.dart';
import 'package:spatially/geomgraph2/geometry_graph.dart';

main() {
  lookupTests();
}

void lookupTests() {
  GeometryFactory geomFactory = new GeometryFactory();
  group("lookup", () {
    test("should be able to lookup a node by coordiate", () {
      var geom1 = geomFactory.createPoint(new Coordinate(0,0));
      var geom2 = geomFactory.createPoint(new Coordinate(1,1));
      var geomGraph = new GeometryGraph(geom1, geom2);
      geomGraph.addPoint(geom1, 1);
      geomGraph.addPoint(geom2, 2);
      var node = geomGraph.nodeByCoordinate(new Coordinate(0,0));
      expect(node.isPresent, isTrue);
      expect(node.value.coordinate, new Coordinate(0,0));
      expect(geomGraph.nodeByCoordinate(new Coordinate(0,0.5)).isPresent, isFalse);
    });

    test("should be able to lookup a forward edge by coordinates", () {
      var geom1 = geomFactory.fromWkt("Linestring(0 0, 1 1)");
      var geom2 = geomFactory.fromWkt("Linestring(0 0, 1 0)");
      var geomGraph = new GeometryGraph(geom1, geom2);
      geomGraph.addLinestring(geom1, 1);
      geomGraph.addLinestring(geom2, 2);
      var edge = geomGraph.forwardEdgeByCoordinates([new Coordinate(0, 0), new Coordinate(1,1)]);
      expect(edge.isPresent, true);
      expect(edge.value.label.coordinates, [new Coordinate(0,0), new Coordinate(1,1)]);

      expect(geomGraph.forwardEdgeByCoordinates([new Coordinate(0,0), new Coordinate(-1,0)]).isPresent,
             isFalse);
    });

    test("should be able to lookup a backward edge by coordinates", () {
      var geom1 = geomFactory.fromWkt("Linestring(0 0, 1 1)");
      var geom2 = geomFactory.fromWkt("Linestring(0 0, 1 0)");
      var geomGraph = new GeometryGraph(geom1, geom2);
      geomGraph.addLinestring(geom1, 1);
      geomGraph.addLinestring(geom2, 2);
      var edge = geomGraph.backwardEdgeByCoordinates([new Coordinate(1, 1), new Coordinate(0,0)]);
      expect(edge.isPresent, true);
      expect(edge.value.label.coordinates, [new Coordinate(1,1), new Coordinate(0,0)]);

      expect(geomGraph.backwardEdgeByCoordinates([new Coordinate(0,0), new Coordinate(-1,0)]).isPresent,
             isFalse);
    });
  });
}