library test_point;

import 'dart:math' as math;

import 'package:unittest/unittest.dart';

import 'package:spatially/geometry.dart';
import 'geometry_tests.dart';

void main() {
  final sample_point = new Point(x: 15.2, y: 188.4);
  runStandardTests("Point", sample_point);
  pointRelations("Point", new Point(x: 0.0, y: 0.0));
  linesegmentRelations("Point", new Point(x: 0.0, y: 0.0));
  multipointRelations("Point", new Point(x: 0.0, y: 0.0));
  testDistanceTo();
  testColinear();
}

testDistanceTo() {
  test("Distance from (0,0) to (1,1)", 
      () => expect(new Point(x: 0.0, y: 0.0).distanceTo(new Point(x: 1.0, y: 1.0)),
                   equals(math.sqrt(2))));
}

testColinear() {
  final p1 = new Point(x: 0.0, y: 0.0);
  final p2 = new Point(x: 1.0, y: 1.0);
  final p3 = new Point(x: 2.0, y: 2.0);
  test("Points p1, p2 and p3 are colinear", () => expect(colinear(p1, p2, p3), isTrue));
  
  final p4 = new Point(x: 1.0, y: 0.0);
  test("Points p1, p2 and p4 are not colinear", () => expect(colinear(p1, p4, p3), isFalse));
}
