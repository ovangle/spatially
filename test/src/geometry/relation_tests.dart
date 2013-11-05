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
void pointRelationTests(String test_lib, Geometry geom) {
  if (geom is! Point) {
    print(geom.bounds);
    assert(geom.bounds == new Bounds(bottom: 0.0, top: 1.0, left: 0.0, right: 1.0));
  }
  pointTouches(test_lib, geom);
  pointEncloses(test_lib, geom);
  pointIntersects(test_lib, geom);
  
}

void pointOperatorTests(String test_lib, Geometry geom) {
  intersectionTests(test_lib, geom, p1);
  intersectionTests(test_lib, geom, p2);
  intersectionTests(test_lib, geom, p3);
  unionTests(test_lib, geom, p1);
  unionTests(test_lib, geom, p2);
  unionTests(test_lib, geom, p3);
  differenceTests(test_lib, geom, p1);
  differenceTests(test_lib, geom, p2);
  differenceTests(test_lib, geom, p3);
}

void multipointRelationTests(String test_lib, Geometry geom) {
  if (geom is! Point) {
    assert(geom.bounds == new Bounds(bottom: 0.0, top: 1.0, left: 0.0, right: 1.0));
  }
  multipointTouches(test_lib, geom);
  multipointEncloses(test_lib, geom);
  multipointIntersection(test_lib, geom);
  multipointUnion(test_lib, geom);
  multipointDifference(test_lib, geom);
}


void multipointOperatorTests(String test_lib, Geometry geom) {
  intersectionTests(test_lib, geom, mp1);
  intersectionTests(test_lib, geom, mp2);
  intersectionTests(test_lib, geom, mp3);
  intersectionTests(test_lib, geom, mp4);
  intersectionTests(test_lib, geom, mp5);
  unionTests(test_lib, geom, mp1);
  unionTests(test_lib, geom, mp2);
  unionTests(test_lib, geom, mp3);
  unionTests(test_lib, geom, mp4);
  unionTests(test_lib, geom, mp5);
  differenceTests(test_lib, geom, mp1);
  differenceTests(test_lib, geom, mp2);
  differenceTests(test_lib, geom, mp3);
  differenceTests(test_lib, geom, mp4);
  differenceTests(test_lib, geom, mp5);
}

void linesegmentRelationTests(String test_lib, Geometry geom) {
  if (geom is! Point) {
    assert(geom.bounds == new Bounds(bottom: 0.0, top: 1.0, left: 0.0, right: 1.0));
  }
  linesegmentTouches(test_lib, geom);
  linesegmentEncloses(test_lib, geom);
  linesegmentIntersects(test_lib, geom);
}

linesegmentOperatorTests(String test_lib, Geometry geom) {
  intersectionTests(test_lib, geom, lseg1);
  intersectionTests(test_lib, geom, lseg2);
  intersectionTests(test_lib, geom, lseg3);
  intersectionTests(test_lib, geom, lseg4);
  unionTests(test_lib, geom, lseg1);
  unionTests(test_lib, geom, lseg2);
  unionTests(test_lib, geom, lseg3);
  unionTests(test_lib, geom, lseg4);
  differenceTests(test_lib, geom, lseg1);
  differenceTests(test_lib, geom, lseg2);
  differenceTests(test_lib, geom, lseg3);
  differenceTests(test_lib, geom, lseg4);
}

linestringRelationTests(String test_lib, Geometry geom) {
  if (geom is! Point) {
    assert(geom.bounds == new Bounds(bottom: 0.0, top: 1.0, left: 0.0, right: 1.0));
  }
  linestringTouches(test_lib, geom);
  linestringEncloses(test_lib, geom);
  linestringIntersects(test_lib, geom);
}

linestringOperatorTests(String test_lib, Geometry geom) {
  intersectionTests(test_lib, geom, lstr1);
  intersectionTests(test_lib, geom, lstr2);
  intersectionTests(test_lib, geom, lstr3);
  intersectionTests(test_lib, geom, lstr4);
  intersectionTests(test_lib, geom, lstr5);
  intersectionTests(test_lib, geom, lstr6);
  intersectionTests(test_lib, geom, lstr7);
  unionTests(test_lib, geom, lstr1);
  unionTests(test_lib, geom, lstr2);
  unionTests(test_lib, geom, lstr3);
  unionTests(test_lib, geom, lstr4);
  unionTests(test_lib, geom, lstr5);
  unionTests(test_lib, geom, lstr6);
  unionTests(test_lib, geom, lstr7);
  differenceTests(test_lib, geom, lstr1);
  differenceTests(test_lib, geom, lstr2);
  differenceTests(test_lib, geom, lstr3);
  differenceTests(test_lib, geom, lstr4);
  differenceTests(test_lib, geom, lstr5);
  differenceTests(test_lib, geom, lstr6);
  differenceTests(test_lib, geom, lstr7);
  
}

