part of geometry_tests;

/* Empty linestring */
final lstr1 = new Linestring();
/* linestring with single point, enclosed by all geometry, incl. Point */
final lstr2 = new Linestring([new Point(x: 0.0, y: 0.0)]);
/* expected to touch geometry at (0,0) and (1,1)*/
final lstr3 = new Linestring([new Point(x: 1.0, y: 0.0),
                              new Point(x: 0.0, y: 0.0),
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
    test("Geometry encloses lseg1", 
        () => expect(geom.encloses(lseg1), isTrue));
    test("Geometry encloses lseg2", 
        () => expect(geom.encloses(lseg2), isTrue));
    if (geom is! Point && geom is! MultiPoint) {
      test("Geometry encloses lseg3", 
          () => expect(geom.encloses(lseg3), isTrue));
      test("Geometry encloses lseg4", 
          () => expect(geom.encloses(lseg4), isTrue));
    }
    test("Geometry does not enclose lseg5", 
        () => expect(geom.encloses(lstr5), isFalse));
  });
}

void linestringEnclosesProper(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: Encloses proper: ", () {
    
  });
}

void linestringIntersects(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: Intersects: ", () {
    
  });
}

void linestringTouches(String test_lib, Geometry geom) {
  group("touches_tests: $test_lib: Touches: ", () {
    
  });
}