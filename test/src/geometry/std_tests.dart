part of geometry_tests;

void runStandardTests(String test_lib, Geometry geom) {
  testTranslate(test_lib, geom);
  testRotate(test_lib, geom);
  testScale(test_lib, geom);
}

const Point O = const Point(x: 0.0, y: 0.0);

void testTranslate(String test_lib, Geometry geom) {
  group("std_tests: $test_lib: Geometry.translate: ", () {
    final geomCentroid = geom.centroid;
    final geom1 = geom.translate(dx: 1.0, dy: 1.0);
    test("Translating geometry translates centroid", () {
      final translatedCentroid = geom.centroid.translate(dx: 1.0, dy: 1.0);
      expect(geom1.centroid, equals(translatedCentroid));
    });
    test("Translating geometry translates bounds", () {
      final translatedBounds = geom.bounds.translate(dx: 1.0, dy: 1.0);
      expect(geom1.bounds, equals(translatedBounds));
    });
    test("translating by inverse dx and dy restores original geometry", () {
      final geom2 = geom1.translate(dx: -1.0, dy: -1.0);
      expect(geom2, equals(geom));
    });
  });
}

void testScale(String test_lib, Geometry geom) {
  //Test depends on O not being centroid
  assert(geom.centroid != O);
  final geomCentroid = geom.centroid;
  final scaledCentroid = geom.centroid.scale(5.0, origin: const Point(x: 0.0, y:0.0));
  var geom1 = geom.scale(5.0, origin: O);
  group("std_tests: $test_lib: Geometry.scale: ", () {
    test("Scaling scales centroid",() {
      //Scaling scales centroid.
      final scaledCentroid = geom.centroid.scale(5.0, origin: O);
      expect(geom1.centroid, equals(scaledCentroid));
    });
    test("Scaling scales bounds", () {
      final scaledBounds = geom.bounds.scale(5.0, origin: O);
      expect(geom1.bounds, equals(scaledBounds));
    });
    test("Scaling by 1.0 does nothing", () {
      expect(geom.scale(1.0, origin: O), equals(geom));
    });
    test("If no origin provided, origin defaults to centroid", () {
      expect(geom.scale(5.0), equals(geom.scale(5.0, origin: geom.centroid)));
    });
    test("Scaling scaled geometry by 1/ratio restores geometry", () {
      expect(geom1.scale(1/5.0, origin: O), geometryCloseTo(geom, 1e-14));
    });
  });
}

testRotate(String test_lib, Geometry geom) {
  //Test depends on O not being centroid.
  assert(geom.centroid != O);
  group("std_tests: $test_lib: Geometry.rotate: ",() {
    final geom1 = geom.rotate(math.PI/4, origin: O);
   
    test("Rotating geometry rotates centroid by same amount", () {
      final rotatedCentroid = geom.centroid.rotate(math.PI/4, origin: O);
      expect(geom1.centroid, pointCloseTo(rotatedCentroid, 1e-15));
    });
    test("Rotating by inverse amount restores original geometry", () {
      final geom2 = geom1.rotate(-math.PI/4, origin: O);
      expect(geom2, geometryCloseTo(geom, 1e-14));
    });
    test("If no origin is provided for rotation, defaults to centroid", () {
      final rotateAboutCentroid = geom.rotate(math.PI/4, origin: geom.centroid);
      final rotateDefault = geom.rotate(math.PI/4);
      expect(rotateDefault, equals(rotateAboutCentroid));
    });
    test("Rotating about centroid preserves the centroid", () {
      final geom2 = geom.rotate(-math.PI/6);
      expect(geom2.centroid, geometryCloseTo(geom.centroid, 1e-15));
    });
    test("Rotating by 2 * PI restores the geometry", () {
      final geom2 = geom.rotate(2 * math.PI, origin: O);
      expect(geom2, geometryCloseTo(geom, 1e-12));
    });
  });
}




