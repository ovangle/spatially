library spatially.algorithm.all_tests;

import 'package:unittest/unittest.dart';
import 'line_intersector_tests.dart' as line_intersector;

main() {
  group("algorithm: ", () {
    line_intersector.main();

  });
}