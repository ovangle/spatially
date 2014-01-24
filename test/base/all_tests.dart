library spatially.base.all_tests;

import 'package:unittest/unittest.dart';

import 'iterables/all_tests.dart' as iterables;
import 'base_tests.dart' as base;
import 'coordinate_test.dart' as coordinate;
import 'error_test.dart' as error;
import 'generator_test.dart' as generator;
import 'graph_tests.dart' as graph;
import 'line_segment_test.dart' as line_segment;
import 'linkedlist_test.dart' as linkedlist;
import 'tuple_tests.dart' as tuple;

void main() {
  group("base: ", () {
    base.main();
    coordinate.main();
    generator.main();
    error.main();
    graph.main();
    line_segment.main();
    linkedlist.main();
    tuple.main();
    iterables.main();
  });
}