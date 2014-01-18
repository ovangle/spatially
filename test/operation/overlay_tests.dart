library spatially.test.overlay;

import 'package:unittest/unittest.dart';
import 'package:spatially/geom/base.dart';
import 'package:spatially/operation/overlay.dart';

main() {
  group("overlay:", () {
    testIntersection();
  });
}

testIntersection() {
  group("intersection", () {
    GeometryFactory geomFactory =
        new GeometryFactory();
    test("empty point intersect empty point should be empty", () {
      var p1 = geomFactory.createEmptyPoint();
      var p2 = geomFactory.createEmptyPoint();
      expect(overlay(p1, p2, OVERLAY_INTERSECTION), p1);
    });
  });
}

