library spatially.algorithm.all_tests;

import 'package:unittest/unittest.dart';
import 'cg_algorithm_test.dart' as cg_algorithm;
import 'line_intersector_tests.dart' as line_intersector;

main() {
  group("algorithm: ", () {
    cg_algorithm.main();
    line_intersector.main();

  });
}