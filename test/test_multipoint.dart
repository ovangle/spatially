library test_multipoint;

import 'dart:math' as math;
import 'package:unittest/unittest.dart';
import 'package:spatially/geometry.dart';
import 'geometry_tests.dart';

void main() {
  final mp1 = new MultiPoint(
      [ new Point(x: 123.4, y: 12.3),
        new Point(x: 1.0, y: 123.44),
        new Point(x: 22.4, y: -121.0),
        new Point(x: 8.4, y: 1.1) ]);
  runStandardTests("MultiPoint", mp1);
  simpleTests();
}

void simpleTests() {
  var mp = new MultiPoint(
      [ new Point(x: 0.0, y: 0.0),
        new Point(x: 1.0, y: 0.0),
        new Point(x: 1.0, y: 1.0),
        new Point(x: 0.0, y: 1.0) ]);
  test("Centroid is (0.5, 0.5)", 
      () => expect(mp.centroid, equals(new Point(x: 0.5, y: 0.5))));
  
  test("Rotate by PI/2 around origin", () {
    final rotated = mp.rotate(math.PI/2, origin: new Point(x: 0.0, y: 0.0));
    final expected =  new MultiPoint(
        [ new Point(x: 0.0, y: 0.0),
          new Point(x: 0.0, y: 1.0),
          new Point(x: -1.0, y: 1.0),
          new Point(x: -1.0, y: 0.0)
        ]);
    expect(rotated, multipointCloseTo(expected, 1e-15));
    print(expected.rotate(math.PI/4));
    
  });
}