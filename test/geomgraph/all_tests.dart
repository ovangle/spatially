library spatially.geomgraph.all_tests;

import 'package:unittest/unittest.dart';

import 'geometry_graph_tests.dart' as geometry_graph;
import 'intersector_tests.dart' as intersector;
import 'location_tests.dart' as location;

main() {
  group("geomgraph", () {
    geometry_graph.main();
    intersector.main();
    location.main();
  });
}