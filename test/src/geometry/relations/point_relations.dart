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

void pointIntersects(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: Point: Intersects: ", () {
    test("Geometry intersects p1",
        () => expect(geom.intersects(p1), isTrue));
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
