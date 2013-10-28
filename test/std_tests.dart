library std_geom_tests;

import 'dart:math';
import 'package:unittest/unittest.dart';

import 'package:spatially/geometry.dart';

void runStandardTests(String test_lib, Geometry geom) {
  testTranslate(test_lib, geom);
  testRotate(test_lib, geom);
  testScale(test_lib, geom);
}

const Point O = const Point(x: 0.0, y: 0.0);

void testTranslate(String test_lib, Geometry geom) {
  final geomCentroid = geom.centroid;
  final translatedCentroid = geom.centroid.translate(dx: 1.0, dy: 1.0);
  var geom1 = geom.translate(dx: 1.0, dy: 1.0);
  test("$test_lib: Translating geom translates the centroid by same amount",
      () => expect(geom1.centroid, withinDistanceOf(translatedCentroid, 1e-15)));
  
  final translatedBounds = geom.bounds.translate(dx: 1.0, dy: 1.0);
  test("$test_lib: Translating geom translates the bounds by same amount",
      () => expect(geom1, 
                   boundsEqual(translatedBounds, 1e-15)));
  
  var geom2 = geom1.translate(dx: -1.0, dy: -1.0);
  test("$test_lib: Translating by inverse restores geometry",
      () => expect(geom2, geometryEquals(geom, 1e-15)));
}


void testScale(String test_lib, Geometry geom) {
  //Test depends on O not being centroid
  assert(geom.centroid != O);
  final geomCentroid = geom.centroid;
  final scaledCentroid = geom.centroid.scale(5.0, origin: const Point(x: 0.0, y:0.0));
  var geom1 = geom.scale(5.0, origin: O);
  test("$test_lib: Scaling scales centroid",
      () => expect(geom1.centroid, geometryEquals(scaledCentroid, 1e-15)));
  
  final scaledBounds = geom.bounds.scale(5.0, origin: O);
  test("$test_lib: Scaling scales bounds",
      () => expect(geom1, boundsEqual(scaledBounds, 1e-15)));
  
  var geom2 = geom.scale(1.0, origin: O);
  test("$test_lib: Scaling by 1.0 does nothing",
      () => expect(geom2, geometryEquals(geom, 1e-15)));
  
  var geom3 = geom.scale(5.0);
  final geom4 = geom.scale(5.0, origin: geomCentroid);
  test("$test_lib: If no origin is provided, defaults to centroid",
      () => expect(geom4, geometryEquals(geom3, 1e-15)));
  
  final geom5 = geom3.scale(1/5.0);
  test("$test_lib: Scaling by 1/ratio restores original geometry",
      () => expect(geom5, geometryEquals(geom, 1e-15)));
}

testRotate(String test_lib, Geometry geom) {
  //Test depends on O not being centroid.
  assert(geom.centroid != O);
  final geomCentroid = geom.centroid;
  final geom1 = geom.rotate(PI/4, origin: O);
  final rotatedCentroid = geom.centroid.rotate(PI / 4, origin: O);
  test("$test_lib: Rotating geometry rotates centroid",
      () => expect(geom1.centroid, geometryEquals(rotatedCentroid, 1e-15)));
  
  final geom2 = geom1.rotate(-PI/4, origin: O);
  test("$test_lib: Inverse rotation restores geometry",
      () => expect(geom2, geometryEquals(geom, 1e-15)));
  

  final geom3 = geom.rotate(-PI/6);
  test("$test_lib: Rotating about centroid preserves the centroid",
      () => expect(geom3.centroid, geometryEquals(geomCentroid, 1e-15)));
  
  
  final geom5 = geom.rotate(PI / 6);
  final geom6 = geom.rotate(PI/6, origin: geomCentroid);
  test("$test_lib: If no origin is provided for rotation, defaults to centroid",
      () => expect(geom5, 
                  geometryEquals(geom6, 1e-15)));
  
  final geom4 = geom.rotate(2 * PI);
  test("$test_lib: Rotating by 2*PI about any point preserves the geometry",
      () => expect(geom4, geometryEquals(geom, 1e-14)));
}

Matcher boundsEqual(Bounds bounds, double tolerance) 
    => new _BoundsEquals(bounds, tolerance);

class _BoundsEquals extends Matcher {
  final Bounds _value;
  final double _delta;
  
  _BoundsEquals(Bounds this._value, double this._delta);
  
  bool matches(item, Map matchState) {
    if (item is Bounds) {
      return item.equalTo(_value, tolerance: _delta);
    }
    if (item is! Geometry) return false;
    return item.bounds.equalTo(_value, tolerance: _delta);
  }
  
  Description describe(Description description) {
    return description
            .add("Bounds equal to ")
            .addDescriptionOf(_value)
            .add(" up to a tolerance of ")
            .addDescriptionOf(_delta);
  }
  
  Description describeMismatch(item, Description mismatchDescription,
                               Map matchState, bool verbose) {
    if (item is Bounds) {
       return mismatchDescription.addDescriptionOf(item);
    }
    if (item is Geometry) {
      return mismatchDescription
          .addDescriptionOf(item)
          .add(" which has bounds of: ")
          .addDescriptionOf(item.bounds);   
    }
    return mismatchDescription
          .addDescriptionOf(item)
          .add(" which is not a geometry or bounds object");
  }
}

/**
 * Matches a geometry to a specified tolerance
 * if [:permute:] is `true`, then the geometry must be planar, and all permutations
 * of the geometry will be matched against [:geom:]
 */
Matcher geometryEquals(Geometry geom, double tolerance, { bool permute: false}) => 
    new _GeometryEquals(geom, tolerance, permute);

class _GeometryEquals extends Matcher {
  final Geometry _value;
  final double _delta;
  final bool _permute;
  const _GeometryEquals(Geometry this._value, double this._delta, this._permute);
  
  bool matches(item, Map matchState) {
    if (item is! Geometry) return false;
    if (_permute) {
      if (item is! Planar) {
        return false;
      }
      for (var i = 0; i < (item as Planar).boundary.length; i++) {
        if ((item as Planar).permuted(i).equalTo(_value, tolerance: _delta)) {
          return true;
        }
      }
    }
    return item.equalTo(_value, tolerance: _delta);
  }
  
  Description describe(Description description) {
    description.add("Geometry equal to ")
               .addDescriptionOf(_value)
               .add(" up to a tolerance of ")
               .addDescriptionOf(_delta);
    if (_permute) {
      description.add(" or equal to a permutation of the geometry");
    }
    return description;
  }
}

Matcher withinDistanceOf(Point p, double distance) => new _PointCloseTo(p, distance);

class _PointCloseTo extends Matcher {
  final Point _expected;
  final double _delta;
  
  const _PointCloseTo(Point this._expected, double this._delta);
  
  matches(item, Map matchState) {
    if (item is! Geometry) return false;
    return (item.distanceTo(_expected) <= _delta);
  }
  
  Description describe(Description description) {
    description.add("A point within ")
               .addDescriptionOf(_delta)
               .add(" radius of $_expected");
  }
  
  Description describeMismatch(item, Description mismatchDescription,
                               Map matchState, bool verbose) {
    if (item is! Geometry) {
      return mismatchDescription.add(" is not a Geometry");
    }
    var dist = item.distanceTo(_expected);
    var diff  = dist - _delta;
    return mismatchDescription
        .add(" is ")
        .add(diff)
        .add(" units outside the expected match radius.");
  }
}

