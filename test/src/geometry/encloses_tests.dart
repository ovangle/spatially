part of geometry_tests;

/**
 * Should be run on a geometry which is expected to enclose (0,0)
 * and not expected to enclose (1,1)
 */
void pointEncloses(String test_lib, Geometry geom) {
  final p1 = new Point(x: 0.0, y: 0.0);
  final p2 = new Point(x: 1.0, y: 1.0);
  
  group("encloses_tests: $test_lib: Point", () {
    test("Geometry encloses $p1", () => expect(geom.encloses(p1), isTrue));
    test("Geometry does not enclose $p2", () => expect(geom.encloses(p2), isFalse));
  });
}

