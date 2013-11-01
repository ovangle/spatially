part of geometry_tests;

final Point p1 = new Point(x: 0.0, y: 0.0);
final Point p2 = new Point(x: 1.0, y: 0.0);
final Point p3 = new Point(x: 0.5, y: 0.5);

void pointEncloses(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: Point: Encloses: ", () {
    test("Geometry encloses $p1", () => expect(geom.encloses(p1), isTrue));
    test("Geometry does not enclose $p2", () => expect(geom.encloses(p2), isFalse));
  });
}

void pointIntersection(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: Point: Intersection/Intersects: ", () {
    test("Geometry intersection p1",
        () => expect(geom.intersection(p1), equals(p1)));
    test("Geometry intersects p1",
        () => expect(geom.intersects(p1), isTrue));
    test("Geometry intersection p2 is null",
        () => expect(geom.intersection(p2), isNull));
    test("Geometry intersects p2",
        () => expect(geom.intersects(p2), isFalse));
  });
}

void pointTouches(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: Point: Touches", () {
    test("Geometry touches p1",
        () => expect(geom.touches(p1), isTrue));
    test("Geometry does not touch p2",
        () => expect(geom.touches(p2), isFalse));
    if (geom is! Point && geom is! MultiPoint) {
      test("Geometry does not touch p3", () {
        () => expect(geom.touches(p3), isFalse);
      });
    }
  });
}

void pointDifference(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: Point: Difference", () {
    if (geom is Point || geom is MultiPoint) {
      test("Taking an enclosed point from a point or multipoint removes the point", () {
        expect(geom.difference(p1), disjoint(p1)); 
      });
    } else {
      test("Taking a single point from a geometry leaves it unchanged", () {
        //Taking a point from anything else 
        expect(geom.difference(p1), equals(geom));
      });
    } 
    test("Difference disjoint point", () {
      expect(geom.difference(p2), equals(geom));
    });
  });
}

void pointUnion(String test_lib, Geometry geom) {
  
  group("relation_tests: $test_lib: Point: Union", () {
    test("Union enclosed p1",
        () => expect(geom.union(p1), equals(geom)));
    test("Union disjoint p2", () {
      if (geom is Multi) {
        expect(geom.union(p2), contains(p2));
      } else {
        expect(geom.union(p2), unorderedEquals([geom, p2]));
      }
    });
  });
}