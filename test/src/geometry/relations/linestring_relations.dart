part of geometry_tests;

/* Empty linestring */
final lstr1 = new Linestring();
/* linestring with single point, enclosed by all geometry, incl. Point */
final lstr2 = new Linestring([new Point(x: 0.0, y: 0.0)]);
/* expected to touch geometry at (0,0) and (1,1)*/
final lstr3 = new Linestring([ new Point(x: 0.0, y: 0.0),
                              new Point(x: 0.0, y: 1.0),
                              new Point(x: 1.0, y: 1.0)]);
/* expected to be enclosedProper by geometry */
final lstr4 = new Linestring([new Point(x: 0.25, y: 0.25),
                              new Point(x: 0.75, y: 0.75)]);
/* expected to enclose geometry, not properly */
final lstr5 = new Linestring([new Point(x: 0.0, y: 0.0), 
                              new Point(x: 0.25, y: 0.25),
                              new Point(x: 0.75, y: 0.75),
                              new Point(x: 1.0, y: 1.0),
                              new Point(x: 1.0, y: 0.0)]);
/* expected to intersect, but not touch geometry */
final lstr6 = new Linestring([new Point(x: 0.25, y: 0.25),
                              new Point(x: 0.5, y: 0.5), 
                              new Point(x: 0.75, y: 0.25)]);
/* Expected to be disjoint from geometry */
final lstr7 = new Linestring([new Point(x: 0.0, y: 0.25),
                              new Point(x: 0.75, y: 1.0),
                              new Point(x: 0.0, y: 1.0)]);

void linestringEncloses(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: Encloses: ", () {
    test("Geometry encloses lstr1", 
        () => expect(geom.encloses(lstr1), isTrue));
    test("Geometry encloses lstr2", 
        () => expect(geom.encloses(lstr2), isTrue));
    if (geom is! Point && geom is! MultiPoint) {
      test("Geometry encloses lstr3", 
          () => expect(geom.encloses(lstr3), isFalse));
      test("Geometry encloses lstr4", 
          () => expect(geom.encloses(lstr4), isTrue));
    }
    test("Geometry does not enclose lstr5", 
        () => expect(geom.encloses(lstr5), isFalse));
  });
}

void linestringEnclosesProper(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: Encloses proper: ", () {
    if (geom is!Point && geom is! MultiPoint) {
      test("geom encloses proper lstr4", 
           () => expect(geom.enclosesProper(lstr4), isTrue));
    }
  });
}

void linestringIntersects(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: Intersects: ", () {
    test("geom intersects lstr3", () => expect(geom.intersects(lstr3), isTrue));
    if (geom is! Point) {
      test("geom intersects lstr6", () => expect(geom.intersects(lstr6), isTrue));
    }
    test("geom does not intersect lstr7", () => expect(geom.intersects(lstr7), isFalse));
  });
}

void linestringTouches(String test_lib, Geometry geom) {
  group("touches_tests: $test_lib: Touches: ", () {
    
    test("geom touches lstr3", () => expect(geom.touches(lstr3), isTrue));
    test("geom touches lstr6", () => expect(geom.touches(lstr6), isFalse));
  });
}