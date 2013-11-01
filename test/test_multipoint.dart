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
  pointRelations("MultiPoint", mp2);
  multipointRelations("MultiPoint", mp2);
  linesegmentRelations("MultiPoint", mp2);
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
