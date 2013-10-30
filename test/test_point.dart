library test_point;

import 'package:unittest/unittest.dart';

import 'package:spatially/geometry.dart';
import 'std_tests.dart';

void main() {
  final sample_point = new Point(x: 15.2, y: 188.4);
  runStandardTests("Point", sample_point);
  testIntersection();
  testTouches();
}

void testIntersection() {
  final p1 = new Point(x: 1.0, y: 1.0);
  final p2 = new Point(x: 1.0, y: 1 + 1e-16);
  test("test_point: $p1 intersection $p2",
      () => expect(p1.intersection(p2),
                   geometryEquals(new Point(x: 1.0, y:1.0), 1e-15)));
}

void testTouches() {
  final p1 = new Point(x: 1.0, y: 1.0);
  final p2 = new Point(x: 1.0, y: 1.0 + 1e-16);
  final p3 = new Point(x: 2.0, y: 1.0);
  test("test_point: $p1 touches $p2",
      () => expect(p1.touches(p2), isTrue));
  test("test_point: $p1 does not touch $p3",
      () => expect(p1.touches(p3), isFalse));
}
