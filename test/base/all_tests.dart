library spatially.base.all_tests;

import 'package:unittest/unittest.dart';

import 'base_tests.dart' as base;
import 'coordinate_test.dart' as coordinate;
import 'graph_tests.dart' as graph;
import 'line_segment_test.dart' as line_segment;
import 'tuple_tests.dart' as tuple;

void main() {
  group("base: ", () {
    base.main();
    coordinate.main();
    graph.main();
    line_segment.main();
    tuple.main();
  });
}