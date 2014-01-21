library spatially.geomgraph.geometry_graph.edge_labelling_test;

import 'package:unittest/unittest.dart';
import 'package:spatially/spatially.dart';
import 'package:spatially/base/tuple.dart';
import 'package:spatially/geomgraph2/geometry_graph.dart';

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
      //geomGraph.labelEdges(1);
      //geomGraph.labelEdges(2);

      for (var edge in geomGraph.edges) {
        print(edge);
      }

      var edge = geomGraph
          .forwardEdgeByCoordinates([new Coordinate(0.0, 0.0), new Coordinate(0.5, 0.0)])
            .value;
      expect(edge.label.locationDatas,
          new Tuple(0,0));
    });
  });
}