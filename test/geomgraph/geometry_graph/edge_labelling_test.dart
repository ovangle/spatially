library spatially.geomgraph.geometry_graph.edge_labelling_test;

import 'package:unittest/unittest.dart';
import 'package:spatially/spatially.dart';
import 'package:spatially/base/tuple.dart';
import 'package:spatially/geom/location.dart' as loc;
import 'package:spatially/geomgraph/geometry_graph.dart';
import 'package:spatially/geomgraph/location.dart';

void main() {
  group("edge labelling", () {
    GeometryFactory geomFactory = new GeometryFactory();
    //No need to test points.
    test("should label the edges of a graph containing linestrings correctly", () {
      var lstr1 = geomFactory.fromWkt("Linestring(0 0, 1 0, 1 1, 0 1)");
      var lstr2 = geomFactory.fromWkt("Linestring(-1 0, 0.5 0, 1 1, 2 1)");

      var geomGraph = new GeometryGraph(lstr1, lstr2);
      geomGraph.addLinestring(lstr1, 1);
      geomGraph.addLinestring(lstr2, 2);
      geomGraph.nodeGraph();
      geomGraph.labelEdges();

      var edge = geomGraph
          .forwardEdgeByCoordinates([new Coordinate(0.0, 0.0), new Coordinate(0.5, 0.0)])
            .value;
      expect(edge.label.locationDatas,
          new Tuple(new Location(lstr1, on: loc.INTERIOR),
                    new Location(lstr2, on: loc.INTERIOR)),
          reason: "linestrings overlap on edge");

      var otherEdges = geomGraph.forwardEdges.where((e) => !identical(e, edge));
      expect(otherEdges.map((e) => e.label.locationDatas),
            everyElement(isIn(
                [ new Tuple(new Location(lstr1, on: loc.EXTERIOR),
                            new Location(lstr2, on: loc.INTERIOR)),
                  new Tuple(new Location(lstr1, on: loc.INTERIOR),
                            new Location(lstr2, on: loc.EXTERIOR))
                ])));
    });

    test("should be able to label the graph of a linestring and polygon correctly", () {
      var poly = geomFactory.fromWkt(
          """POLYGON( 
                (0 0, 3 0, 3 3, 0 3, 0 0),
                (1 1, 2 1, 2 2, 1 2, 1 1) )
          """);
      var lstr = geomFactory.fromWkt(
          """LINESTRING(1.5 1.5, 1.5 3.5)""");

      GeometryGraph geomGraph = new GeometryGraph(lstr, poly);
      geomGraph.addLinestring(lstr, 1);
      geomGraph.addPolygon(poly, 2);
      geomGraph.nodeGraph();
      geomGraph.labelEdges();

      var e1 =
          geomGraph.forwardEdgeByCoordinates(
              [new Coordinate(1.5, 1.5), new Coordinate(1.5, 2.0)])
          .value;
      expect(e1.label.locationDatas,
             new Tuple(new Location(lstr, on: loc.INTERIOR),
                       new Location(poly, on: loc.EXTERIOR)),
             reason: "center of poly to edge of hole");

      var e2 =
          geomGraph.forwardEdgeByCoordinates(
              [new Coordinate(1.5, 2.0), new Coordinate(1.5, 3.0)])
                .value;
      expect(e2.label.locationDatas,
              new Tuple(new Location(lstr, on: loc.INTERIOR),
                        new Location(poly, on: loc.INTERIOR)),
              reason: "edge of hole to shell of poly");

      var e3 =
          geomGraph.forwardEdgeByCoordinates(
              [new Coordinate(1.5, 3.0), new Coordinate(1.5, 3.5)])
                .value;
      expect(e3.label.locationDatas,
              new Tuple(new Location(lstr, on: loc.INTERIOR),
                        new Location(poly, on: loc.EXTERIOR)),
              reason: "edge of shell to outside poly");

      var otherEdges = geomGraph.forwardEdges.where((e) => ![e1,e2,e3].contains(e));
      expect(otherEdges.map((e) => e.label.locationDatas),
             everyElement(
                 isIn([ new Tuple(new Location(lstr, on: loc.EXTERIOR),
                                  new Location(poly, on: loc.BOUNDARY, left:loc.EXTERIOR, right: loc.INTERIOR)),
                        new Tuple(new Location(lstr, on: loc.EXTERIOR),
                                  new Location(poly, on: loc.BOUNDARY, left:loc.INTERIOR, right: loc.EXTERIOR))
                      ])));
    });

    test("should be able to label the edges of overlapping polygons correctly", () {
      var poly1 = geomFactory.fromWkt(
          """POLYGON( 
              (0 0, 3 0, 3 3, 0 3, 0 0),
              (1 1, 2 1, 2 2, 1 2, 1 1) )
          """);
      var poly2 = geomFactory.fromWkt(
          """POLYGON(
              (1.5 1.5, 4.5 1.5, 4.5 4.5, 1.5 4.5, 1.5 1.5),
              (2.5 2.5, 3.5 2.5, 3.5 3.5, 2.5 3.5, 2.5 2.5))
          """);
      var geomGraph = new GeometryGraph(poly1, poly2);
      geomGraph.addPolygon(poly1, 1);
      geomGraph.addPolygon(poly2, 2);
      geomGraph.nodeGraph();
      geomGraph.labelEdges();

      //Location of the shell of poly1.
      var shellLoc = new Location(poly1, on: loc.BOUNDARY, left: loc.EXTERIOR, right: loc.INTERIOR);

      var e11 = geomGraph.forwardEdgeByCoordinates([new Coordinate(0,0), new Coordinate(3,0), new Coordinate(3, 1.5)]);
      expect(e11.value.label.locationDatas,
             new Tuple(shellLoc, new Location(poly2, on: loc.EXTERIOR)),
             reason: "portion of poly1 shell outside poly2");

      var e12 = geomGraph.forwardEdgeByCoordinates([new Coordinate(3,1.5), new Coordinate(3,2.5)]);
      expect(e12.value.label.locationDatas,
            new Tuple(shellLoc, new Location(poly2, on: loc.INTERIOR)),
            reason: "portion of poly1 shell between shell and hole of poly2");

      var e13 = geomGraph.forwardEdgeByCoordinates([new Coordinate(3.0, 2.5), new Coordinate(3,3), new Coordinate(2.5, 3)]);
      expect(e13.value.label.locationDatas,
             new Tuple(shellLoc, new Location(poly2, on: loc.EXTERIOR)),
             reason: "portion of poly1 shell inside hole of poly2");

      var e14 = geomGraph.forwardEdgeByCoordinates([new Coordinate(2.5, 3), new Coordinate(1.5, 3)]);
      expect(e14.value.label.locationDatas,
             new Tuple(shellLoc, new Location(poly2, on: loc.INTERIOR)),
             reason: "portion of poly1 shell between shell and hole of poly2 (2)");

      var e15 = geomGraph.forwardEdgeByCoordinates([new Coordinate(1.5, 3), new Coordinate(0, 3), new Coordinate(0,0)]);
      expect(e11.value.label.locationDatas,
             new Tuple(shellLoc, new Location(poly2, on: loc.EXTERIOR)),
             reason: "portion of poly1 shell outside poly2 (2)");

      var holeLoc = new Location(poly1, on: loc.BOUNDARY, left: loc.INTERIOR, right: loc.EXTERIOR);
      var e21 = geomGraph.forwardEdgeByCoordinates([new Coordinate(1.0, 1.0), new Coordinate(2.0, 1.0), new Coordinate(2.0, 1.5)]);
      expect(e21.value.label.locationDatas,
             new Tuple(holeLoc, new Location(poly2, on: loc.EXTERIOR)),
             reason: "portion of poly1 hole outside poly2");

      var e22 = geomGraph.forwardEdgeByCoordinates([new Coordinate(2.0, 1.5), new Coordinate(2.0, 2.0), new Coordinate(1.5, 2.0)]);
      expect(e22.value.label.locationDatas,
             new Tuple(holeLoc, new Location(poly2, on: loc.INTERIOR)),
             reason: "portion of poly1 hole inside poly2");

      var e23 = geomGraph.forwardEdgeByCoordinates([new Coordinate(1.5, 2.0), new Coordinate(1.0, 2.0), new Coordinate(1.0, 1.0)]);
      expect(e23.value.label.locationDatas,
          new Tuple(holeLoc, new Location(poly2, on: loc.EXTERIOR)),
          reason: "portion of poly1 hole outside poly2 (2)");

    });
    test("should be able to label the edges of adjacent polygons correctly", () {
      var poly1 = geomFactory.fromWkt("POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))");
      var poly2 = geomFactory.fromWkt("POLYGON((1 0, 2 0, 2 1, 1 1, 1 0))");

      var geomGraph = new GeometryGraph(poly1, poly2);
      geomGraph.addPolygon(poly1, 1);
      geomGraph.addPolygon(poly2, 2);
      geomGraph.nodeGraph();
      geomGraph.labelEdges();

      for(var edge in geomGraph.edges) {
        print(edge);
      }

      var testEdge = geomGraph
          .forwardEdgeByCoordinates([new Coordinate(1,0), new Coordinate(1,1)]);

      expect(testEdge.value.label.locationDatas,
             new Tuple(new Location(poly1, on: loc.BOUNDARY, left: loc.EXTERIOR, right: loc.INTERIOR),
                       new Location(poly2, on: loc.BOUNDARY, left: loc.INTERIOR, right: loc.EXTERIOR)));
    });
  });
}