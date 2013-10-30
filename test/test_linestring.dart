library test_linestring;

import 'dart:math' as math;

import 'package:unittest/unittest.dart';
import 'package:spatially/geometry.dart';

import 'std_tests.dart';

final unitSquare = new Linestring(
    [ new Point(x: 0.0, y: 0.0),
      new Point(x: 1.0, y: 0.0),
      new Point(x: 1.0, y: 1.0),
      new Point(x: 0.0, y: 1.0),
      new Point(x: 0.0, y: 0.0)
    ]);

final testLine1 = new Linestring(
    [ new Point(x: 0.0, y: 0.0),
      new Point(x: 1.0, y: 1.0),
      new Point(x: 2.0, y: 2.0),
      new Point(x: 2.0, y: 3.0)
    ]);

void main() {
  runStandardTests("Linestring (unitSquare)", unitSquare);
  runStandardTests("Linestring (testLine1)", testLine1);
  testSimplify();
  testFromSegments();
  testGeometryImpl();
  testInsert();
  testConcat();
  testTouches();
}

void testSimplify() {
  final duplicatePoints = 
      new Linestring([new Point(x:0.0, y:0.0),
                      new Point(x:1.0, y:1.0),
                      new Point(x:1.0, y:0.0),
                      new Point(x:1.0, y:0.0), //Doubled point
                      new Point(x:1.0, y:1.0), //Duplicate, non-adjacent point not removed
                      new Point(x:2.2, y:2.2),
                      new Point(x:2.2, y:2.2),
                      new Point(x:2.2, y:2.2), //Tripled point
                      new Point(x:2.2 + 1e-14, y:2.2), //Almost equal, but greater than tolerance
                      new Point(x:0.5, y:1.0),
                      new Point(x:0.5 + 1e-17, y:1.0), //Doubled point, not exactly equal
                      new Point(x:0.0, y:0.0)
                     ]);
  final simplifiedLinestring = 
      new Linestring([new Point(x:0.0, y:0.0),
                      new Point(x:1.0, y:1.0),
                      new Point(x:1.0, y:0.0),
                      new Point(x:1.0, y:1.0),
                      new Point(x:2.2, y:2.2),
                      new Point(x:2.2 + 1e-14, y:2.2), //Almost equal, but greater than tolerance
                      new Point(x:0.5, y:1.0),
                      new Point(x:0.0, y:0.0)]);
  test("test_linestring: simplify removes duplicate points",
      () => expect(duplicatePoints.simplify(tolerance:1e-15),
                   geometryEquals(simplifiedLinestring, 1e-15)));
  
  final inlinePoints = 
      new Linestring([new Point(x:0.0, y:0.0),
                      new Point(x:0.5, y:0.5), //Removed, inline
                      new Point(x:1.0, y:1.0), //Removed, also inline
                      new Point(x:2.0, y:2.0),
                      new Point(x:3.0, y:2.0),         //Removed, inline
                      new Point(x:4.0, y:2.0 + 1e-16), //Removed, inline
                      new Point(x: 5.0, y:2.0),
                      new Point(x:5.5, y:2.5),
                      new Point(x: 6.0, y:2.5 + 1e-14), //Not removed, outside tolerance
                      new Point(x: 7.0, y:2.5)]);
  final inlineResult =
      new Linestring([new Point(x:0.0, y:0.0),
                      new Point(x:2.0, y:2.0),
                      new Point(x: 5.0, y:2.0),
                      new Point(x:5.5, y:2.5),
                      new Point(x: 6.0, y:2.5 + 1e-14), //Not removed, outside tolerance
                      new Point(x: 7.0, y:2.5)]);
  /*   
  test("test_linestring: simplify removes inline points",
      () => expect(inlinePoints.simplify(), geometryEquals(inlineResult, 1e-15)));
  */
}

/**
 * This should not be included. 
 */
void testFromSegments() {
  List<LineSegment> connectedSegments = 
      [ new LineSegment(new Point(x:1.0, y: 2.0), new Point(x: 1.0, y: 1.0)),
        new LineSegment(new Point(x:1.0, y: 1.0), new Point(x: 1.5, y: 1.5)),
        new LineSegment(new Point(x:1.5, y: 1.5), new Point(x: 1.75, y: 2.0))];
  Linestring fromConnected = new Linestring.fromLines(connectedSegments);
  
  Linestring fromPoints = new Linestring(
      [ new Point(x: 1.0, y: 2.0),
        new Point(x: 1.0, y: 1.0),
        new Point(x: 1.5, y: 1.5),
        new Point(x: 1.75, y: 2.0)]);
  test("test_linestring: Connected segments are not included twice",
         () => expect(fromConnected,
                      geometryEquals(fromPoints, 1e-15)));
  
  List<LineSegment> unconnectedSegments = 
      [ new LineSegment(new Point(x: 1.0, y: 2.0), new Point(x: 1.5, y: 1.5)),
        new LineSegment(new Point(x: 1.0, y: 1.0), new Point(x: 1.5, y: 1.5))];
  
  var tryCreateLstr = () => new Linestring.fromLines(unconnectedSegments);
  test("test_linestring: If segments in list aren't connected, throws an InvalidGeometry",
      () => expect(
          tryCreateLstr, throwsA(new isInstanceOf<InvalidGeometry>())));
  var tryCreateLstr2 = () => new Linestring.fromLines(unconnectedSegments, reverse: true);
  test("test_linestring: If reverse is allowed, a linestring results",
      () => expect(
          tryCreateLstr2, isNot(throwsA(new isInstanceOf<InvalidGeometry>()))));
}

void testEncloses() {
  var p1 = new Point(x:1.0, y:0.5);
  test("test_linestring: unitSquare encloses $p1",
      () => expect(unitSquare.encloses(p1), isTrue));
  
  var p2 = new Point(x:0.5, y:0.5);
  test("test_linestring: unitSquare does not enclose $p2",
      () => expect(unitSquare.encloses(p2), isFalse));
  
  var lstr = new Linestring([ new Point(x:0.0, y:0.0),
                              new Point(x:0.5, y:1e-16),
                              new Point(x:0.0, y:1.0)]);
  var lseg = new LineSegment(new Point(x:0.25, y:0.25),
                             new Point(x:0.75, y:0.75));
  test("test_linestring: $lstr encloses $lseg",
      () => expect(lstr.encloses(lseg), isTrue));
  
  var lstr2 = new Linestring([new Point(x:0.0, y:0.0),
                              new Point(x:0.5, y:1e-14),
                              new Point(x:0.0, y:1.0)]);
  test("test_linestring: $lstr2 does not enclose $lseg",
      () => expect(lstr2.encloses(lseg), isFalse));
}

void testTouches() {
  final lstr = new Linestring([new Point(x: 0.0, y: 0.0), new Point(x: 1.0, y: 0.0), new Point(x: 1.0, y: 1.0)]);
  
  final p1 = new Point(x: 0.0, y: 0.0);
  final p2 = new Point(x: 1.0, y: 0.0);
  test("$lstr touches $p1",
      () => expect(lstr.touches(p1), isTrue));
  test("$lstr does not touch $p2",
      () => expect(lstr.touches(p2), isFalse));
  
  final lseg1 = new LineSegment(new Point(x: 0.0, y: 0.0), new Point(x:1.0, y: 1.0));
  final lseg2 = new LineSegment(new Point(x: 1.0, y: 0.0), new Point(x:0.0, y: 1.0));
  test("$lstr touches $lseg1",
      () => expect(lstr.touches(lseg1), isTrue));
  test("$lstr touches $lseg2",
      () => expect(lstr.touches(lseg2), isFalse));
  
  final ring1 = new Ring([new Point(x: -1.0, y: -1.0), 
                          new Point(x: -1.0, y: 1.0),
                          new Point(x: 0.5, y: 0.5),
                          new Point(x: -1.0, y: -1.0)]);
  final ring2 = new Ring([new Point(x: -0.5, y: -0.5),
                          new Point(x: -0.5, y: 0.5),
                          new Point(x: 0.6, y: 0.5),
                          new Point(x: 0.5, y: -0.5),
                          new Point(x: -0.5, y: -0.5)]);
  test("test_linestring: $lstr touches $ring1",
      () => expect(lstr.touches(ring1), isTrue));
  test("test_linestring: $lstr does not touch $ring2",
      () => expect(lstr.touches(ring2), isFalse));
}

void testGeometryImpl() {
  var unitBounds = new Bounds(bottom: 0.0, top: 1.0, left: 0.0, right: 1.0);
  test("test_linestring: Unit square has unit bounds",
      () => expect(unitSquare.bounds,
                  equals(unitBounds)));
  test("test_linestring: Unit square center at <0.5,0.5>",
      () => expect(unitSquare.centroid, equals(new Point(x: 0.5, y: 0.5))));
  test("test_linestring: Unit square span is 4.0",
       () => expect(unitSquare.span, equals(4.0)));
  
  var line1Bounds = new Bounds(bottom: 0.0, top: 3.0, left: 0.0, right: 2.0);
  test("test_linestring: testLine1 has expected bounds",
      () => expect(testLine1.bounds,
                    equals(line1Bounds)));
  test("test_linestring: testLine1 center at <1.25, 1.5>",
      () => expect(testLine1.centroid,
                   equals(new Point(x: 1.25, y: 1.5))));
  test("test_linestring: testLine1 span is 2 * sqrt(2) + 1",
      () => expect(testLine1.span,
                   closeTo(2 * math.sqrt(2) + 1, 0.05)));
}

void testInsert() {
  var lstr  = new Linestring([new Point(x: 0.0, y: 0.0), new Point(x: 1.0, y:1.0)]);
  var lstr2 = lstr.append(new Point(x: 2.0, y:1.0));
  test("test_linestring: append to $lstr",
      () => expect(lstr2, 
                   geometryEquals(new Linestring([new Point(x: 0.0, y:0.0),
                                                  new Point(x: 1.0, y:1.0),
                                                  new Point(x: 2.0, y:1.0)]),
                                  1e-15)));
  test("test_linestring: append to unitSquare",
      () => expect(unitSquare.append(new Point(x: -0.5, y: 0.5), preserve_closure: true),
                   geometryEquals(new Linestring([
                      new Point(x: 0.0, y: 0.0),
                      new Point(x: 1.0, y: 0.0),
                      new Point(x: 1.0, y: 1.0),
                      new Point(x: 0.0, y: 1.0),
                      new Point(x: -0.5, y: 0.5),
                      new Point(x: 0.0, y: 0.0)
                   ]), 1e-15)));
  test("test_linestring: insert into unitSquare at 0",
       () => expect(unitSquare.insert(0, new Point(x: 0.5, y: -0.5), preserve_closure: true),
                    geometryEquals(new Linestring([
                      new Point(x: 0.5, y: -0.5),
                      new Point(x: 0.0, y: 0.0),
                      new Point(x: 1.0, y: 0.0),
                      new Point(x: 1.0, y: 1.0),
                      new Point(x: 0.0, y: 1.0),
                      new Point(x: 0.5, y: -0.5)
                    ]), 1e-15)));
  test("test_linestring: insert into unitSquare at 3",
      () => expect(unitSquare.insert(3, new Point(x: 1.5, y: 0.5), preserve_closure: true),
                  geometryEquals(new Linestring([
                      new Point(x: 0.0, y: 0.0),
                      new Point(x: 1.0, y: 0.0),
                      new Point(x: 1.0, y: 1.0),
                      new Point(x: 1.5, y: 0.5),
                      new Point(x: 0.0, y: 1.0),
                      new Point(x: 0.0, y: 0.0) 
                      ]), 1e-15)));
  
}

void testConcat() {
  var lstr1 = new Linestring([new Point(x: 0.0, y: 1.0), new Point(x: 1.0, y:1.0)]);
  var lstr2 = new Linestring([new Point(x: 1.0, y: 1.0), new Point(x: 2.0, y:1.0)]);
  var expected = new Linestring([new Point(x: 0.0, y: 1.0),
                                 new Point(x: 1.0, y: 1.0),
                                 new Point(x: 2.0, y: 1.0)]);
  
  
  test("test_linestring: concat $lstr1 and $lstr2",
      () => expect(lstr1.concat(lstr2),
                   geometryEquals(expected, 1e-15)));
  
  var lstr3 = new Linestring([new Point(x: 4.0, y: 4.0), new Point(x: 5.0, y:5.0)]);
  test("test_linestring: cannot concat $lstr1 and $lstr3",
      () => expect(() => lstr1.concat(lstr3),
                   throwsA(new isInstanceOf<InvalidGeometry>())));
  
  var lstr4 = new Linestring([new Point(x: 2.0, y: 2.0), new Point(x: 1.0, y: 1.0)]);
  var expected2 = new Linestring([  new Point(x: 0.0, y:1.0), 
                                    new Point(x:1.0, y: 1.0),
                                    new Point(x:2.0, y: 2.0)]);
  test("test_linestring: concatenate with reverse",
      () => expect(lstr1.concat(lstr4, reverse: true),
                  geometryEquals(expected2, 1e-15)));
}
