part of geometry_tests;


/**
 * Should be called on a Geometry which encloses (0,0)
 * and is disjoint from (1,1) 
 */
void pointDifference(String test_lib, Geometry geom) {
  final p1 = new Point(x: 0.0, y: 0.0);
  assert(geom.encloses(p1));
  final p2 = new Point(x: 1.0, y: 1.0);
  assert(geom.disjoint(p2));
  
  group("difference_tests: $test_lib: Point", () {
    if (geom is Point) {
      test("Point difference enclosed point is null", () {
        //Taking a point from a point is empty
        expect(geom.difference(p1), isNull);
      });
    } else if (geom is MultiPoint) {
      test("MultiPoint difference enclosed point does not contain enclosed point", () {
        //Taking a point from a multipoint removes the point
        expect(geom.difference(p1), isNot(contains(p1)));
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