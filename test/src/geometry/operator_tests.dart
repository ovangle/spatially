part of geometry_tests;

void intersectionTests(String test_lib, Geometry geom1, Geometry geom2) {
  final showGeoms =
      "\tgeom1: $geom1\n"
      "\tgeom2: $geom2\n";
  group("operator_tests: $test_lib: Intersection", () {
    if (geom1.intersects(geom2)) {
      test("If geom1 intersects geom2, "
           "then intersection is not null.\n$showGeoms", 
           () {
              expect(geom1.intersection(geom2), isNotNull);
           });
      test("If geom1 intersects geom2, "
          "then intersection enclosed by both geom1 and geom2", () {
            expect(geom1.intersection(geom2), enclosedBy(geom1));
            expect(geom1.intersection(geom2), enclosedBy(geom2));
          });
    }
    if (geom1.disjoint(geom2)) {
      test("If geom1 disjoint geom2, "
           "then intersection is null\n$showGeoms", () {
        expect(geom1.intersection(geom2), isNull);       
      });
    }
    if (geom1.encloses(geom2)) {
      if (geom2 is! Multi) {
        test("If geom1 encloses geom2, "
            "then intersection is geom2\n$showGeoms", () {
              expect(geom1.intersection(geom2), equals(geom2));       
            });
      } else {
        
        if ((geom2 as Multi).isEmpty) {
          test("If geom1 encloses geom2, "
              " and geom1 multi and empty"
              "then intersection is null\n$showGeoms", () {
                expect(geom1.intersection(geom2), isNull);       
              });
        } else if ((geom2 as Multi).length == 1) {
          test("If geom1 encloses geom2, "
              " and geom1 multi and length == 1"
              "then intersection is the single element\n$showGeoms", () {
                expect(geom1.intersection(geom2), 
                       equals((geom2 as Multi).single));       
              });
        } else {
          test("If geom1 encloses geom2, "
              " and geom1 multi and length > 1"
              "then intersection is geom2\n$showGeoms", () {
                expect(geom1.intersection(geom2), equals(geom2));       
              });
        }
      }
    }
    if (geom1.touches(geom2)) {
      if (geom1 is! Planar && geom2 is! Planar && geom1.touches(geom2)) {
        test("If geom1 touches geom2 and neither is planar\n"
             "then intersection is a Point or MultiPoint\n$showGeoms", () {
          expect(geom1.intersection(geom2), 
                 anyOf(new isInstanceOf<Point>(), new isInstanceOf<MultiPoint>()));      
         });
      } else {
        //TODO:
        test("If geom1 touches geom2 and one is Planar, \n$showGeoms", () {});
      }
    }
  });
}

void unionTests(String test_lib, Geometry geom1, Geometry geom2) {
  final showGeoms =
      "\tgeom1: $geom1\n"
      "\tgeom2: $geom2\n";
  final union = geom1.union(geom2);
  group("operator_tests: $test_lib: Union", () {
    test("Union encloses both geometries\n$showGeoms", () {
      expect(union, encloses(geom1));
      expect(union, encloses(geom2));
    });
    if (geom1.encloses(geom2)) {
      test("If geom1 encloses geom2, "
           "then the union enclosedBy geom1\n$showGeoms", () {
             expect(union, enclosedBy(geom1));
           });
    }
    if (geom1.enclosedBy(geom2)) {
      test("If geom1 enclosed by geom2, "
           " then the union enclosedBy geom2\n$showGeoms", () {
             expect(union, enclosedBy(geom2));
           });
    }
  });
}

void differenceTests(String test_lib, Geometry geom1, Geometry geom2) {
  final showGeoms = 
      "\tgeom1: $geom1\n"
      "\tgeom2: $geom2\n";
  final diff = geom1.difference(geom2);
  group("operator_tests: $test_lib: Difference", () {
    if (geom1.disjoint(geom2)) {
      test("If geom1 disjoint geom2, "
          "then geom1 difference geom2 is geom1\n$showGeoms", () {
        expect(diff, equals(geom1));
      });
    } else {
      if (geom1.enclosedBy(geom2)) {
        test("If geom1 enclosed by geom2, "
             "then geom1 difference geom2 is null", () {
               expect(geom1.difference(geom2), isNull);
             });
      }
      if (geom1 is Point || geom1 is MultiPoint) {
        test("if geom1 is Point or geom1 is MultiPoint, "
             "then geom1.difference(geom2) is not equal to geom1", () {
               expect(geom1.difference(geom2), isNot(equals(geom1)));
             });
      }
      
    }
  });
}