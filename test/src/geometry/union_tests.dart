part of geometry_tests;


/**
 * Should be called on a geometry which encloses (0,0)
 * and is disjoint from (1,1).
 */
void pointUnion(String test_lib, Geometry geom) {
  final Point p1 = new Point(x: 0.0, y: 0.0);
  assert(geom.encloses(p1));
  final Point p2 = new Point(x: 1.0, y: 1.0);
  assert(geom.disjoint(p2));
  group("union_tests: $test_lib: Point", () {
    test("Union enclosed p1",
        () => expect(geom.union(p1), equals(geom)));
    test("Union disjoint p2", 
        () => expect(geom.union(p2), unorderedEquals([geom, p2])));
  });
}