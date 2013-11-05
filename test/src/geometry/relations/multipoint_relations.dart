part of geometry_tests;

final mp1 = new MultiPoint([]);
final mp2 = new MultiPoint([new Point(x: 0.0, y: 0.0)]);
final mp3 = new MultiPoint(
    [new Point(x: 0.0, y: 0.0), 
     new Point(x: 1.0, y: 1.0),
     new Point(x: 0.5, y: 0.5)]);
final mp4 = new MultiPoint(
    [new Point(x: 1.0, y: 0.0),
     new Point(x: 0.5, y: 0.5),
     new Point(x: 1.0, y: 1.0)]);
final mp5= new MultiPoint(
    [new Point(x: 0.0, y: 1.0),
     new Point(x: 0.5, y: 1.0),
     new Point(x: 0.0, y: 0.5)]);
final mp6 = new MultiPoint(
    [new Point(x: 0.0, y: 0.0), 
     new Point(x: 0.0, y: 1.0),
     new Point(x: 1.0, y: 0.0)]);


/**
 * The geometry is expected to:
 *  -- Enclose mp2
 *  -- If not a point, enclose mp3
 *  -- Intersect mp4, but not touch it
 *  -- Touch mp5
 *  -- Be disjoint from mp5
 */
void multipointEncloses(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: MultiPoint: Encloses", () {
    test("Encloses empty multi point", 
        () => expect(geom.encloses(mp1), isTrue));
    test("Encloses mp2", () => expect(geom.encloses(mp2), isTrue));
    if (geom is! Point) {
      test("Encloses mp3", 
           () => expect(geom.encloses(mp3), isTrue));
    }
    test("Does not enclose mp4", () => expect(geom.encloses(mp4), isFalse));
    test("Does not enclose mp5", () => expect(geom.encloses(mp5), isFalse));
    test("Does not enclose mp6", () => expect(geom.encloses(mp6), isFalse));
  });
}

void multipointIntersects(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: Multipoint: Intersects", () {
    test("Does not intersect empty multipoint", () => expect(geom.encloses(mp1), isFalse));
    test("Intersects mp2", () => expect(geom.intersects(mp2), isTrue));
    test("Intersects mp3", () => expect(geom.intersects(mp3), isTrue));
    test("Intersect mp4", () => expect(geom.intersects(mp4), isTrue));
    test("Not Intersect mp5", () => expect(geom.intersects(mp5), isFalse));
    test("Intersect mp6", () => expect(geom.intersects(mp6), isTrue));
  });
}

void multipointTouches(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: Multipoint: Touches", () {
    test("Does not touch empty multipoint", () => expect(geom.touches(mp1), isFalse));
    test("Touches mp2", 
        () => expect(geom.touches(mp2), isTrue));
    if (geom is! Point && geom is! MultiPoint) {
      test("Does not touch mp3", () => expect(geom.touches(mp3), isFalse));
    } else {
      test("Touches mp3", () => expect(geom.touches(mp3), isTrue));
    }
    if (geom is! MultiPoint) {
      test("Does not touch mp4", 
          () => expect(geom.touches(mp4), isFalse));
    }
    test("Does not touch mp5", 
        () => expect(geom.touches(mp5), isFalse));
    test("Touches mp6", () => expect(geom.touches(mp6), isTrue));
  });
}

void multipointIntersection(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: Multipoint: Intersection", () {
    test("Intersection with empty multipoint", () => expect(geom.intersection(mp1), isNull));
    test("Intersection with mp2", () => 
        expect(geom.intersection(mp2), equals(new Point(x: 0.0, y: 0.0))));
    test("Intersection with mp3", () {
      if (geom is Point ) {
        expect(geom.intersection(mp3), equals(new Point(x: 0.0, y: 0.0)));
      } else {
        expect(geom.intersection(mp3), encloses(mp3));
      }
    });
    test("Intersection with mp4", () {
      expect(geom & mp4, anyOf(isNull, enclosedBy(mp4)));
      expect(geom & mp4, anyOf(isNull, enclosedBy(geom)));
    });
    test("Intersection with disjoint mp5", () => expect(geom.intersection(mp5), isNull));
    test("Intersection with mp6", 
        () => expect(geom.intersection(mp6), equals(new Point(x: 0.0, y: 0.0))));
  });
}

void multipointUnion(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: MultiPoint: Union", () {
    test("Union with empty multipoint", () {
      expect(geom.union(mp1), encloses(geom));
    });
    test("Union with mp2", () {
      expect(geom.union(mp2), encloses(geom)); 
    });
    if (geom is! Point) {
      test("Union with mp3", () => equals(geom));
    }
    test("Union with mp4", () {
      expect(geom.union(mp4), encloses(mp4)); 
      expect(geom.union(mp4), encloses(geom));
    });
    test("Union with disjoint mp5", () {
      expect(geom.union(mp5), encloses(mp5)); 
      expect(geom.union(mp5), encloses(geom));
    });
    test("Union with mp6", () {
      expect(geom.union(mp6), encloses(mp6));
      expect(geom.union(mp6), encloses(geom));
    });
    
  });
}

void multipointDifference(String test_lib, Geometry geom) {
  group("relation_tests: $test_lib: Multipoint: Difference: ", () {
    test("Difference empty multipoint", () => expect(geom.difference(mp1), equals(geom)));
    test("geom difference mp2", () {
      expect(mp2.difference(geom), isNull);
      expect(geom.difference(mp2), 
             anyOf(isNull, enclosedBy(geom)));
    });
    test("geom difference mp4", () {
      if (geom is MultiPoint) {
        expect(geom.difference(mp4).disjoint(mp4), isTrue);
      } else {
        //Taking a point away from a geometry which is not Nodal or Multi-Nodal
        //doesn't affect the geometry.
        expect(geom.difference(mp4), equals(geom));
      }
    });
    test("geom difference mp6", () {
      if (geom is Point || geom is MultiPoint) {
        expect(mp6.difference(geom), disjoint(geom));
      } else {
        expect(geom.difference(mp6), equals(geom));
      }
    });
  });
}