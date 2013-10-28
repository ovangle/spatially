library test_geometry;

import 'test_bounds.dart' as test_bounds;
import 'test_linesegment.dart' as test_linesegment;
import 'test_point.dart' as test_point;
import 'test_linestring.dart' as test_linestring;
import 'test_tessel.dart' as test_tessel;
import 'test_ring.dart' as test_ring;

import 'test_geometry_list.dart' as test_geometry_list;

void main() {
  test_point.main();
  test_bounds.main();
  //test_latlng.main();
  test_linesegment.main();
  test_linestring.main();
  test_tessel.main();
  test_ring.main();
  test_geometry_list.main();
}
