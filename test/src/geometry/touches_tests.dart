part of geometry_tests;

/**
 * Should be called on a geometry which is expected to touch (0,0)
 * and to not touch (1,1).
 * If the geometry is not a Point or a MultiPoint, it is also
 * expected to enclose the point (0.5, 0.5) but not to touch it.
 */
void pointTouches(String test_lib, Geometry geom) {
  final p1 = new Point(x: 0.0, y: 0.0);
  final p2 = new Point(x: 1.0, y: 1.0);
  final p3 = new Point(x: 0.5, y: 0.5);
  group("touches_tests: $test_lib: Point", () {
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