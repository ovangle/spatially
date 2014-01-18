library spatially.base.all_tests;

import 'package:unittest/unittest.dart';

import 'base_tests.dart' as base;
import 'graph_tests.dart' as graph;
import 'tuple_tests.dart' as tuple;

void main() {
  group("base: ", () {
    base.main();
    graph.main();
    tuple.main();
  });
}