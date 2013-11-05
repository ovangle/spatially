library test_ring;

import 'package:unittest/unittest.dart';

import 'package:spatially/geometry.dart';
import 'geometry_tests.dart';

final unitSquare = new Ring([new Point(x: 0.0, y: 0.0),
                             new Point(x: 1.0, y: 0.0),
                             new Point(x: 1.0, y: 1.0),
                             new Point(x: 0.0, y: 1.0),
                             new Point(x: 0.0, y: 0.0)]);

final cShape    = new Ring([ new Point(x: 0.0, y: 0.0),
                             new Point(x: 3.0, y: 0.0),
                             new Point(x: 3.0, y: 1.0),
                             new Point(x: 2.0, y: 1.0),
                             new Point(x: 2.0, y: 2.0),
                             new Point(x: 3.0, y: 2.0),
                             new Point(x: 3.0, y: 3.0),
                             new Point(x: 0.0, y: 3.0),
                             new Point(x: 0.0, y: 0.0)]);

void main() {
  runStandardTests("Ring", unitSquare);
  testPermuted();
  testEncloses();
  testIntersection();
  testTesselation();
  testSimplify();
}

void testPermuted() {
  final cShape1    = new Ring([new Point(x: 3.0, y: 0.0),
                               new Point(x: 3.0, y: 1.0),
                               new Point(x: 2.0, y: 1.0),
                               new Point(x: 2.0, y: 2.0),
                               new Point(x: 3.0, y: 2.0),
                               new Point(x: 3.0, y: 3.0),
                               new Point(x: 0.0, y: 3.0),
                               new Point(x: 0.0, y: 0.0),
                               new Point(x: 3.0, y: 0.0)]); 
  test("test_ring: permute defaults to 1",
      () => expect(cShape.permute(), equals(cShape1)));
  final cShape4    = new Ring([new Point(x: 2.0, y: 2.0),
                               new Point(x: 3.0, y: 2.0),
                               new Point(x: 3.0, y: 3.0),
                               new Point(x: 0.0, y: 3.0),
                               new Point(x: 0.0, y: 0.0),
                               new Point(x: 3.0, y: 0.0),
                               new Point(x: 3.0, y: 1.0),
                               new Point(x: 2.0, y: 1.0),
                               new Point(x: 2.0, y: 2.0)]);
  test("test_ring: permute 4", 
      () => expect(cShape.permute(4), equals(cShape4)));
  test("test_ring: permute wraps around (length - 1)",
      () => expect(cShape.permute(cShape.length - 1), equals(cShape)));
}

void testEncloses() {
  final p1 = new Point(x:0.5, y:0.5);
  test("test_ring: unit square encloses $p1",
      () => expect(unitSquare.encloses(p1), isTrue));
  final p2 = new Point(x:1.5, y:1.5);
  test("tets_ring: unit square does not enclose $p2",
      () => expect(unitSquare.encloses(p2), isFalse));
  final p3 = new Point(x: 2.5, y: 1.5);
  test("test_ring: cShape does not enclose $p3",
      () => expect(cShape.encloses(p3), isFalse));
  
  final lseg1 = new LineSegment(new Point(x: 0.5, y:0.5),
                                new Point(x: 0.5, y:2.5));
  test("test_ring: cShape encloses lseg1",
      () => expect(cShape.encloses(lseg1), isTrue));
  final lseg2 = new LineSegment(new Point(x: 2.0, y: 0.5),
                                new Point(x: 2.0, y: 2.5));
  test("test_ring: cShape encloses $lseg2",
      () => expect(cShape.encloses(lseg2), isTrue));
  final lseg3 = new LineSegment(new Point(x: 2.5, y: 0.5),
                                new Point(x: 2.5, y: 2.5));
  test("test_ring: cShape does not enclose $lseg3",
      () => expect(cShape.encloses(lseg3), isFalse));
  
  final lseg4 = new LineSegment(new Point(x: 3.0, y: 1.0),
                                new Point(x: 3.0, y: 2.0));
  test("test_ring: cShape does not enclose $lseg4",
      () => expect(cShape.encloses(lseg4), isFalse));
  final lseg5 = new LineSegment(new Point(x: 0.0, y: 0.0),
                                new Point(x: 1.0, y: 1.0));
  test("test_ring: unitSquare encloses $lseg5",
      () => expect(unitSquare.encloses(lseg5), isTrue));
  
  final lstr = new Linestring([ new Point(x: 2.5, y: 0.5),
                                new Point(x: 1.5, y: 0.5),
                                new Point(x: 1.5, y: 2.5),
                                new Point(x: 2.5, y: 2.5)
                              ]);
  test("test_ring: cShape encloses $lstr",
      () => expect(cShape.encloses(lstr), isTrue));
}

void testIntersection() {
  final p1 = new Point(x: 0.5, y: 0.5);
  test("test_ring: unitSquare intersects p1",
      () => expect(unitSquare.intersects(p1), isTrue));
  test("test_ring: unitSqure intersection $p1 is $p1",
      () => expect(unitSquare.intersection(p1), equals(p1, 1e-15)));
  
  final lseg1 = new LineSegment(new Point(x: 1.5, y: 1.5), new Point(x: 2.5, y:1.5));
  test("test_ring: cShape intersects $lseg1",
      () => expect(cShape.intersects(lseg1), isTrue));
  final expected1 = new LineSegment(new Point(x: 1.5, y: 1.5), new Point(x: 2.0, y: 1.5));
  test("test_ring: cShape intersection $lseg1 is $expected1",
      () => expect(cShape.intersection(lseg1), equals(expected1, 1e-15)));
  
  final lseg2 = new LineSegment(new Point(x: 2.5, y:1.0), new Point(x: 2.5, y: 2.5));
  final expected2 = new MultiGeometry(
      [ new Point(x: 2.5, y: 1.0),
        new LineSegment(new Point(x: 2.5, y: 2.0), new Point(x: 2.5, y: 2.5))
      ]);
  test("test_ring: cShape intersection $lseg2 is $expected2",
      () => expect(cShape.intersection(lseg2), equals(expected2, 1e-15)));
}

testTesselation() {
  final expect1 = [ new Tessel(new Point(x: 0.0, y: 0.0), new Point(x: 1.0, y: 0.0), new Point(x: 1.0, y: 1.0)),
                    new Tessel(new Point(x: 0.0, y: 0.0), new Point(x: 1.0, y: 1.0), new Point(x: 0.0, y: 1.0))
                  ].toSet();
  test("test_ring: tesselate unit square",
      () => expect(unitSquare.tesselate(), equals(expect1)));
}

testSimplify() {
  final r1 = new Ring([new Point(x: 0.0, y: 0.0),
                       new Point(x: 1.0, y: 0.0),
                       new Point(x: 1.0, y: 1.0),
                       new Point(x: -1.0, y: 1.0),
                       new Point(x: -1.0, y: 0.0),
                       new Point(x: -1.0, y: 0.0),
                       new Point(x: 0.0, y: 0.0)]);
  final expect1 = new Ring([new Point(x: 1.0, y: 0.0),
                            new Point(x: 1.0, y: 1.0),
                            new Point(x: -1.0, y: 1.0),
                            new Point(x: -1.0, y: 0.0),
                            new Point(x: 1.0, y: 0.0)]);
  test("test_ring: colinear around start of ring",
      () => expect(r1.simplify(), equals(expect1)));
}