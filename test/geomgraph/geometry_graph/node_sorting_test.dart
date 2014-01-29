library spatially.geomgraph.geometry_graph.node_sorting;

import 'package:unittest/unittest.dart';
import 'package:spatially/spatially.dart';
import 'package:spatially/geomgraph/geometry_graph.dart';

main() {
  GeometryFactory geomFactory = new GeometryFactory();
  test("should order edges around nodes", () {
    var g1 = geomFactory.fromWkt("LINESTRING(0 0, 1 1, -1 1, 0 0)");
    var g2 = geomFactory.fromWkt("LINESTRING(0 0, 1 -1, -1 -1, 0 0)");
    GeometryGraph geomGraph = new GeometryGraph(g1, g2);
    geomGraph.addGeometry(g1);
    geomGraph.addGeometry(g2);
    var node = geomGraph.nodeByCoordinate(new Coordinate(0,0));

    expect(node.terminatingEdges.map((e) => e.coordinates),
           [ [ new Coordinate(0, 0), new Coordinate(1,-1), new Coordinate(0,-1)],
             [ new Coordinate(-1,-1), new Coordinate(0,0)],
             [ new Coordinate(0, 0), new Coordinate(1,1), new Coordinate(-1,1), new Coordinate(0,0)]
           ]);
  });
}