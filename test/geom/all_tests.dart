library spatially.geom.all_tests;

import 'package:unittest/unittest.dart';

import 'boundary_tests.dart' as boundary;
import 'centroid_tests.dart' as centroid;
import 'dispatch_test.dart' as dispatch;
import 'factory_test.dart' as factory;
import 'interior_point_tests.dart' as interior_point;
import 'intersection_matrix_tests.dart' as intersection_matrix;

main() {
  group("geom: ", () {
  boundary.main();
  centroid.main();
  dispatch.main();
  factory.main();
  interior_point.main();
  intersection_matrix.main();
  });
}