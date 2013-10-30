part of geometry_tests;



/**
 * Should be called on a geometry which is expected to intersect (0,0)
 * and to not intersect (1.0, 1.0).
 */
void pointIntersection(String test_lib, Geometry geom) {
  final Point p1 = new Point(x: 0.0, y: 0.0);
  final Point p2 = new Point(x: 1.0, y: 1.0);
  group("intersection_tests: $test_lib: Point", () {
    test("Geometry intersection p1",
        () => expect(geom.intersection(p1), equals(p1)));
    test("Geometry intersects p1",
        () => expect(geom.intersects(p1), isTrue));
    test("Geometry does not intersection p2",
        () => expect(geom.intersection(p2), isNull));
    test("Geometry intersects p2",
        () => expect(geom.intersects(p2), isFalse));
  });
}