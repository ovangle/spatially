part of geometry_tests;

/**
 * A suite of simple tests for testing the relations
 * on the geometry tests.
 * 
 * [:geom:] is expected to
 * -- if geom is not a point, have bounds = (bottom: 0.0, top: 1.0, left: 0.0, right: 1.0)
 * -- touch/enclose the point (0,0)
 * -- be disjoint from (1,0)
 * -- not touch the point (0.5, 0.5)
 */
void pointRelations(String test_lib, Geometry geom) {
  if (geom is! Point) {
    print(geom.bounds);
    assert(geom.bounds == new Bounds(bottom: 0.0, top: 1.0, left: 0.0, right: 1.0));
  }
  pointTouches(test_lib, geom);
  pointEncloses(test_lib, geom);
  pointIntersection(test_lib, geom);
  pointUnion(test_lib, geom);
  pointDifference(test_lib, geom);
}

void multipointRelations(String test_lib, Geometry geom) {
  if (geom is! Point) {
    assert(geom.bounds == new Bounds(bottom: 0.0, top: 1.0, left: 0.0, right: 1.0));
  }
  multipointTouches(test_lib, geom);
  multipointEncloses(test_lib, geom);
  multipointIntersection(test_lib, geom);
  multipointUnion(test_lib, geom);
  multipointDifference(test_lib, geom);
}

void linesegmentRelations(String test_lib, Geometry geom) {
  if (geom is! Point) {
    assert(geom.bounds == new Bounds(bottom: 0.0, top: 1.0, left: 0.0, right: 1.0));
  }
  linesegmentTouches(test_lib, geom);
  linesegmentEncloses(test_lib, geom);
  linesegmentIntersects(test_lib, geom);
  linesegmentIntersection(test_lib, geom);
  linesegmentUnion(test_lib, geom);
  linesegmentDifference(test_lib, geom);
}

