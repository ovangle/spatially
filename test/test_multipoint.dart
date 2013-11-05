library test_multipoint;

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
  final mp2 = new MultiPoint(
      [ new Point(x: 0.0, y: 0.0),
        new Point(x: 0.5, y: 0.5),
        new Point(x: 1.0, y: 1.0)]);
  
  pointRelationTests("MultiPoint", mp2);
  multipointRelationTests("MultiPoint", mp2);
  linesegmentRelationTests("MultiPoint", mp2);
  linestringRelationTests("MultiPoint", mp2);
  
  pointOperatorTests("MultiPoint", mp2);
  multipointOperatorTests("MultiPoint", mp2);
  linesegmentOperatorTests("MultiPoint", mp2);
  linestringOperatorTests("MultiPoint", mp2);
  testEncloses();
}

void testEncloses() {
  final mp2 = new MultiPoint(
      [ new Point(x: 1.0, y: 0.0),
        new Point(x: 0.5, y: 0.5),
        new Point(x: 1.0, y: 1.0),
        new Point(x: 0.0, y: 0.0)]);
  test("test_multipoint: encloses (0,0)", () {
    expect(mp2.encloses(new Point(x: 0.0, y: 0.0)), isTrue);
  });
  test("test_multipoint: encloses", () {
    expect(mp2.encloses(new MultiPoint(
              [ new Point(x: 1.0, y: 0.0),
                new Point(x: 0.5, y: 0.5),
                new Point(x: 1.0, y: 1.0)])),
           isTrue);
  });
  
}
