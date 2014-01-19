library spatially.base.line_segment_test;

import 'package:unittest/unittest.dart';
import 'package:spatially/base/coordinate.dart';
import 'package:spatially/base/line_segment.dart';

main() {
  group("linesegment", () {
    test("should be able to get the midpoint of a linesegment", () {
      var lseg = new LineSegment(new Coordinate(0, 0), new Coordinate(1,1));
      expect(lseg.midpoint, new Coordinate(0.5, 0.5));
    });
  });
}