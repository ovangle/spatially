library spatially.all_tests;

import 'algorithm/all_tests.dart' as algorithm;
import 'base/all_tests.dart' as base;
import 'convert/all_tests.dart' as convert;
import 'geom/all_tests.dart' as geom;
import 'geomgraph/all_tests.dart' as geomgraph;
import 'operation/all_tests.dart' as operation;

void main() {
  base.main();
  algorithm.main();
  convert.main();
  geom.main();
  geomgraph.main();
  operation.main();
}