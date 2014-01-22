library spatially.geomgraph.geometry_graph.edge_splitting_test;

import 'package:unittest/unittest.dart';
import 'package:spatially/spatially.dart';
import 'package:spatially/geomgraph/geometry_graph.dart';
import 'package:spatially/geomgraph/intersector.dart';

EdgeSetIntersector _edgeSetIntersector = SIMPLE_EDGE_SET_INTERSECTOR;

main() {
  group("edge splitting", () {
    GeometryFactory geomFactory = new GeometryFactory();

    test("segment intersection at first segment of linestring", () {
      var lstr1 = geomFactory.fromWkt("Linestring(0 0, 1 0, 1 1, 0 1)");
      var lstr2 = geomFactory.fromWkt("Linestring(-1 0, 0.5 0, 1 1, 2 1)");

      var geomGraph = new GeometryGraph(lstr1, lstr2);
      geomGraph.addLinestring(lstr1, 1);
      geomGraph.addLinestring(lstr2, 2);

      Iterable<IntersectionInfo> infos = SIMPLE_EDGE_SET_INTERSECTOR(new List.from(geomGraph.edges));
      var testEdge1 = geomGraph
          .forwardEdgeByCoordinates([new Coordinate(0,0), new Coordinate(1,0), new Coordinate(1,1), new Coordinate(0,1)])
          .value.edge;
      expect(testEdge1.splitCoordinates(infos),
             [ [new Coordinate(0,0), new Coordinate(0.5, 0)],
               [new Coordinate(0.5,0), new Coordinate(1,0), new Coordinate(1,1)],
               [new Coordinate(1,1), new Coordinate(0,1)]
             ],
             reason: "linestring 1");

      var testEdge2 = geomGraph
          .forwardEdgeByCoordinates([new Coordinate(-1,0), new Coordinate(0.5,0), new Coordinate(1,1), new Coordinate(2,1)])
          .value.edge;
      expect(testEdge2.splitCoordinates(infos),
             [ [ new Coordinate(-1,0),  new Coordinate(0,0)    ],
               [ new Coordinate(0,0),   new Coordinate(0.5, 0) ],
               [ new Coordinate(0.5,0), new Coordinate(1,1)    ],
               [ new Coordinate(1,1),   new Coordinate(2,1)    ]
             ],
             reason: "linestring 2");

    });

    test("segment intersection as last segment of polygon", () {
      var poly1 = geomFactory.fromWkt("POLYGON((0 0, 1 0, 1 1, 0 1, 0 0))");
      var poly2 = geomFactory.fromWkt("POLYGON((1 0, 2 0, 2 1, 1 1, 1 0))");

      GeometryGraph geomGraph = new GeometryGraph(poly1, poly2);
      geomGraph.addPolygon(poly1, 1);
      geomGraph.addPolygon(poly2, 2);

      Iterable<IntersectionInfo> infos = SIMPLE_EDGE_SET_INTERSECTOR(new List.from(geomGraph.edges));
      var testEdge =
          geomGraph
          .forwardEdgeByCoordinates([new Coordinate(1,0), new Coordinate(2,0), new Coordinate(2,1), new Coordinate(1,1), new Coordinate(1,0)])
          .value.edge;

      expect(testEdge.splitCoordinates(infos),
             [ [new Coordinate(1, 0), new Coordinate(2, 0), new Coordinate(2,1), new Coordinate(1,1)],
               [new Coordinate(1, 1), new Coordinate(1, 0)]
             ]);

      var testEdge2 =
          geomGraph
          .forwardEdgeByCoordinates([new Coordinate(0,0), new Coordinate(1,0), new Coordinate(1,1), new Coordinate(0,1), new Coordinate(0,0)])
          .value.edge;
      expect(testEdge2.splitCoordinates(infos),
            [ [new Coordinate(0, 0), new Coordinate(1, 0)],
              [new Coordinate(1, 0), new Coordinate(1, 1)],
              [new Coordinate(1, 1), new Coordinate(0, 1), new Coordinate(0,0)]
            ], reason: "poly2 split coords");
    });
  });

}