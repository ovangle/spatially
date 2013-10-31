part of geometry_tests;

final lseg1 = new LineSegment(new Point(x: 0.0, y: 0.0), new Point(x: 1.0, y: 1.0));
final lseg2 = new LineSegment(new Point(x: 0.0, y: 0.25), new Point(x: 0.75, y: 1.0));
final lseg3 = new LineSegment(new Point(x: 1.0, y: 0.0), new Point(x: 0.0, y: 1.0));
final lseg4 = new LineSegment(new Point(x: 0.0, y: 0.0), new Point(x: 1.0, y: 0.0));
/**
 * If geom is not a point or multipoint:
 *    Geometry is expected to enclose the linesegment
 *    (0,0) -> (1,1)
 * and to not enclose the linesegment
 * (0.25, 0) -> (0.75, 1)
 * and to not enclose the linesegment, but to intersect it
 * (1,0) -> (0,1)
 * and to touch the linesegment
 * (0,0) -> (1,0)
 * 
 */
linesegmentEncloses(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: LineSegment: Encloses: ", () {
    if (geom is! Point && geom is! MultiPoint) {
      test("geom encloses lseg1", () => expect(geom.encloses(lseg1), isTrue));
    } else {
      test("Point and multipoint do not enclose lseg1",
          () => expect(geom.encloses(lseg1), isFalse));
    }
    test("geom does not enclose lseg2", 
        () => expect(geom.encloses(lseg2), isFalse));
    test("geom does not enclose lseg3",
        () => expect(geom.encloses(lseg3), isFalse));
  });
}

linesegmentTouches(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: LineSegment: Touches: ", () {
    test("geom touches lseg4", 
        () => expect(geom.touches(lseg4), isTrue));
    if (geom is! Point && geom is! MultiPoint) {
      test("geom does not touch lseg1", 
          () => expect(geom.touches(lseg1), isFalse));
    }
    test("geom does not touch lseg2", 
        () => expect(geom.touches(lseg2), isFalse));
    test("geom does not touch lseg3", 
        () => expect(geom.touches(lseg3), isFalse));
  });
}

linesegmentIntersects(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: LineSegment: Intersects: ", () {
    test("geom intersects lseg1", () {
      expect(geom.intersects(lseg1), isTrue);
    });
    test("geom does not intersect lseg2", () {
      expect(geom.intersects(lseg2), isFalse);
    });
    if (geom is! Point) {
      test("geom intersects lseg3", () {
        expect(geom.intersects(lseg3), isTrue);
      });
    }
    test("geom intersects lseg4", () {
      expect(geom.intersects(lseg4), isTrue);
    });
  });
}

linesegmentIntersection(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: LineSegment: Interection: ", () {
    if (geom is! Point && geom is! MultiPoint) {
      test("geom intersection lseg1 is lseg1", () {
        expect(geom.intersection(lseg1), equals(lseg1));
      });
    }
    test("geom intersection lseg2 is null", () {
      expect(geom.intersection(lseg2), isNull);
    });
    if (geom is! Point) {
      test("geom intersection lseg3 is not null", () {
        expect(geom.intersection(lseg3), isNotNull);
      });
    }
    test("geom intersection lseg4 is a Point or LineSegment", () {
      expect(geom.intersection(lseg4), 
             anyOf(new isInstanceOf<Point>(),
             new isInstanceOf<LineSegment>()));
    });
  });
}

linesegmentUnion(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: LineSegment: Union:", () {
    if (geom is Point || geom is MultiPoint) {
      test("Point or multipoint union point is lseg1", () {
        expect(geom.union(lseg1), equals(lseg1));
      });
    } else {
      test("geom union lseg1 is geom", () {
        expect(geom.union(lseg1), equals(geom));
      });
    }
    test("Geom union lseg2 contains geom and lseg2", () {
      expect(geom.union(lseg2), contains(lseg2));
      expect(geom.union(lseg2), contains(geom));
    });
  });
}

linesegmentDifference(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: LineSegment: Difference", () {
    if (geom is Point || geom is MultiPoint) {
      test("lseg1 difference geom is lseg1", () {
        expect(lseg1.difference(geom), equals(lseg1));
      });
    } else {
      test("lseg1 difference geom is null", () {
        expect(lseg1.difference(geom), isNull);
      });
      test("geom difference lseg4 is geom", () {
        expect(geom.difference(lseg4), equals(geom));
        expect(lseg4.difference(geom), equals(lseg4));
      });
    }
    test("geom difference lseg2 is geom", () {
      expect(geom.difference(lseg2), equals(geom));
      expect(lseg2.difference(geom), equals(lseg2));
    });
  });
}