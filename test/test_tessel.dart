library test_tessel;

import 'package:unittest/unittest.dart';
import 'package:spatially/geometry.dart';

import 'std_tests.dart';

void main() {
  var sample = new Tessel(
      new Point(x: 0.0, y: 0.0),
      new Point(x: 1.0, y: 0.0),
      new Point(x: 0.0, y: 1.0));
  
  runStandardTests("Tessel", sample);
  testPermuted();
  testEncloses();
  testIntersection();
  testTesselTesselIntersection();
  testUnion();
}

void testPermuted() {
  var tesl = new Tessel(
      new Point(x: 0.0, y: 0.0),
      new Point(x: 1.0, y: 1.0),
      new Point(x: 1.0, y: 0.0));
  test("test_tessel: Permute defaults to 1",
      () => expect(tesl.permuted(), 
                   geometryEquals(new Tessel(new Point(x: 1.0, y: 1.0), 
                                             new Point(x: 1.0, y: 0.0), 
                                             new Point(x: 0.0, y: 0.0)), 
                                  1e-15)
                   ));
}

void testTouches() {
  var tesl = new Tessel(
      new Point(x: 0.0, y: 0.0),
      new Point(x: 1.0, y: 1.0),
      new Point(x: 1.0, y: 0.0));
}

void testEncloses() {
  final tes = new Tessel(
      new Point(x: 0.0, y: 0.0),
      new Point(x: 2.0, y: 0.0),
      new Point(x: 0.0, y: 2.0));
  test("test_tessel: Point on edge of $tes is enclosed",
      () => expect(tes.encloses(new Point(x:1.0, y:1.0), tolerance: 1e-15), isTrue));
  
  test("test_tessel: Point inside $tes is enclosed",
      () => expect(tes.encloses(new Point(x: 0.5, y:0.5), tolerance: 1e-15), isTrue));
  
  test("test_tessel: Point outside $tes is not enclosed",
      () => expect(tes.encloses(new Point(x: 2.0, y:2.0), tolerance: 1e-15), isFalse));
  
  final tes1 = new Tessel(
      new Point(x: 0.0, y: 0.0),
      new Point(x: 1.0, y: 0.0),
      new Point(x: 1.0, y: 1.0));
  final p1 = new Point(x: -0.5, y: -0.5);
  test("test_tessel: $tes1 does not enclose $p1",
      () => expect(tes1.encloses(p1), isFalse));
  
  final tes2 = new Tessel(
      new Point(x:0.0, y: 0.0),
      new Point(x:0.0, y: 2.0),
      new Point(x:2.0, y: 0.0));
  test("test_tessel: Point inside $tes2 is enclosed",
      () => expect(tes2.encloses(new Point(x: 0.5, y:0.5)), isTrue));
  test("test_tessel: Point outside $tes2 is not enclosed",
      () => expect(tes2.encloses(new Point(x:2.0, y:2.0)), isFalse));
}

void testIntersection() {
  var tes1 = new Tessel(new Point(x: 0.0, y: 0.0), new Point(x: 1.0, y: 0.0), new Point(x: 1.0, y: 1.0));
  var p1 = new Point(x: 0.75, y: 0.25);
  test("test_tessel: $tes1 intersection $p1",
      () => expect(tes1.intersection(p1), geometryEquals(p1, 1e-15)));
  
  var p2 = new Point(x: 0.25, y: 0.75);
  test("test_tessel: $tes1 intersection $p2",
      () => expect(tes1.intersection(p2), isNull));
  
  var lseg1 = new LineSegment(new Point(x: 1.0, y: 0.0), new Point(x: 0.0, y: 1.0));
  test("test_tessel: $tes1 intersection $lseg1",
      () => expect(tes1.intersection(lseg1), 
                   geometryEquals(new LineSegment(new Point(x: 1.0, y: 0.0), new Point(x: 0.5, y: 0.5)),
                                  1e-15)));
  var lseg2 = new LineSegment(new Point(x: 0.5, y: 0.5), new Point(x: 0.0, y: 1.0));
  test("test_tessel: $tes1 intersection $lseg2",
      () => expect(tes1.intersection(lseg2), 
                  geometryEquals(new Point(x: 0.5, y: 0.5), 1e-15)));
  
  
  final lseg3 = new LineSegment(new Point(x: -0.5, y: -0.5), new Point(x: 0.5, y: 0.5));
  test("test_tessel: intersection on extension of edge",
      () => expect(tes1.intersection(lseg3), 
                   geometryEquals(new LineSegment(new Point(x: 0.0, y: 0.0), new Point(x: 0.5, y: 0.5)),
                                  1e-15)));
  
  final lseg4 = new LineSegment(new Point(x: 0.5,y: -0.5), new Point(x: 0.5, y: 1.0));
  test("test_tessel: intersection which doesn't contain either endpoint",
      () => expect(tes1.intersection(lseg4),
                  geometryEquals(new LineSegment(new Point(x: 0.5, y: 0.0), new Point(x: 0.5, y: 0.5)),
                                 1e-15)));
  
  final lseg5 = new LineSegment(new Point(x: 0.0, y: -1.0), new Point(x: 0.0, y: 1.0));
  test("test_tessel: line intersects at corner",
      () => expect(tes1.intersection(lseg5),
                  geometryEquals(new Point(x: 0.0, y: 0.0), 1e-15)));
  
}

void testTesselTesselIntersection() {
  final tesl1 = new Tessel(new Point(x: 0.0, y: 0.0), new Point(x: 2.0,y: 0.0), new Point(x: 2.0,y: 2.0));
  //CASE 1: Disjoint
  final tesl2 = tesl1.translate(dx: 5.0);
  test("test_tessel: intersection of disjoint Tessels",
      () => expect(tesl1.intersection(tesl2), isNull));
  //CASE 2a: Touch at point
  final tesl3 = tesl1.translate(dy: 2.0);
  test("test_tessel: intersection touch at point",
      () => expect(tesl1.intersection(tesl3), geometryEquals(new Point(x: 2.0, y: 2.0), 1e-15)));
  //CASE 2b: Touch at point, but enclosing
  final tesl4 = new Tessel(new Point(x: 1.0, y: 0.0), new Point(x: 2.0, y: 1.0), new Point(x: 0.5, y: 0.5));
  final expect0 = new Ring([new Point(x: 1.0, y: 0.0),
                            new Point(x: 2.0, y: 1.0),
                            new Point(x: 0.5, y: 0.5),
                            new Point(x: 1.0, y: 0.0)]);
  test("test_Tessel: intersection encloses argument",
      () => expect(tesl1.intersection(tesl4), geometryEquals(expect0, 1e-15, permute: true)));
  
  //CASE 3: Touch along edge
  final tesl5 = new Tessel(new Point(x: 0.0, y: 0.0), new Point(x: 1.0, y: 0.0), new Point(x: 1.0, y: -1.0));
  test("test_tessel: intersection along edge",
      () => expect(tesl1.intersection(tesl5), 
                   geometryEquals(new LineSegment(new Point(x: 0.0, y: 0.0), new Point(x: 1.0, y: 0.0)),
                                  1e-15)));
  final tesl6 = tesl1.scale(0.5, origin: new Point(x: 0.0, y: 0.0))
                     .translate(dx: -0.5, dy: -0.5);
  final expect1 = 
      new Tessel(new Point(x: 0.0, y: 0.0),
                 new Point(x: 0.5, y: 0.5),
                 new Point(x: 0.5, y: 0.0));
  test("test_tessel: intersection along common edge",
      () => expect(tesl1.intersection(tesl6), geometryEquals(expect1, 1e-15)));
  
  final tesl7 = new Tessel(new Point(x: 0.0, y: 0.0), new Point(x: 3.0, y:0.0), new Point(x: 1.5, y: 3.0));
  final tesl8 = new Tessel(new Point(x: 0.0, y: 2.0), new Point(x: 3.0, y:2.0), new Point(x: 1.5, y: -1.0));
  final expect2 = 
      new Ring([new Point(x: 1.0, y: 0.0),
                new Point(x: 0.5, y: 1.0),
                new Point(x: 1.0, y: 2.0),
                new Point(x: 2.0, y: 2.0),
                new Point(x: 2.5, y: 1.0),
                new Point(x: 2.0, y: 0.0),
                new Point(x: 1.0, y: 0.0)]);
  test("test_tessel: star of david intersection",
      () => expect(tesl7.intersection(tesl8), geometryEquals(expect2, 1e-15)));
}

void testUnion() {
  final a = new Point(x: 0.0, y: 0.0);
  final b = new Point(x: 1.0, y: 0.0);
  final c = new Point(x: 1.0, y: 1.0);
  final tesl1 = new Tessel(a, b, c);
  
  final tesl2 = tesl1.scale(0.5, origin: new Point(x: 0.0, y: 0.0));
  test("test_tessel: tesl1 union an enclosed tesl",
      () => expect(tesl1.union(tesl2), equals(new Ring([a, b, c, a]))));
      
  final tesl3 = tesl1.translate(dx: 0.5);
  final expected = new Ring([a, c, new Point(x: 1.0, y: 0.5), c.translate(dx: 0.5), b.translate(dx: 0.5), a]);
  test("test_tessel: tesl1 union an overlapping tesl",
      () => expect(tesl1.union(tesl3), geometryEquals(expected, 1e-15)));
}