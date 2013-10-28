library test_bentley_ottman;

import 'package:unittest/unittest.dart';

import 'package:layers/geometry.dart';
import 'package:layers/algorithms.dart';

void main() {
  testSet1();
  testSet2();
  testSet3();
  testSet4();
  testSet5();
  testSet6();
  testSet7();
  testSet8();
}

void testSet1() {
  /*
  var lseg1 = new LineSegment(new Point(x: 1.0, y: 5.0), new Point(x: 3.0, y: 1.0));
  var lseg2 = new LineSegment(new Point(x: 1.0, y: 1.0), new Point(x:5.0, y: 6.0));
  */
  final segmentSet = new Set<LineSegment>();
  segmentSet.add(new LineSegment(new Point(x: 0.0, y: 4.0), new Point(x: 4.0, y: 4.0)));
  segmentSet.add(new LineSegment(new Point(x: 1.0, y: 5.0), new Point(x: 3.0, y: 1.0)));
  segmentSet.add(new LineSegment(new Point(x: 1.0, y: 1.0), new Point(x: 5.0, y: 6.0)));
  test("test_bentley ottman: Simple base case",
      () => expect(bentleyOttmanIntersections(segmentSet),
                   unorderedEquals([new Point(x: 2.230769230769231, y: 2.5384615384615383), 
                                    new Point(x: 1.5, y: 4.0),
                                    new Point(x: 3.4, y: 4.0)])));
}

void testSet2() {
  final segmentSet = new Set<LineSegment>();
  segmentSet.add(new LineSegment(new Point(x: 0.0, y: 0.0), new Point(x: 4.0, y: 4.0)));
  segmentSet.add(new LineSegment(new Point(x: 0.0, y: 2.0), new Point(x: 4.0, y: -2.0)));
  
  segmentSet.add(new LineSegment(new Point(x: 1.0, y: 0.0), new Point(x: 4.0, y: 3.0)));
  test("test bentley_ottman: Two segments with same left yitude",
      () => expect(bentleyOttmanIntersections(segmentSet),
                   unorderedEquals([new Point(x: 1.0, y: 1.0),
                                    new Point(x: 1.5, y: 0.5)])));
}

void testSet3() {
  final segmentSet = new Set<LineSegment>();
  segmentSet.add(new LineSegment(new Point(x: 0.0, y: 0.0), new Point(x: 4.0, y: 4.0)));
  segmentSet.add(new LineSegment(new Point(x: 0.0, y: 2.0), new Point(x: 4.0, y: 2.0)));
  segmentSet.add(new LineSegment(new Point(x: 0.0, y: 4.0), new Point(x: 4.0, y: 0.0)));
  segmentSet.add(new LineSegment(new Point(x: 2.0, y: 4.0), new Point(x: 4.0, y: 3.0)));
  segmentSet.add(new LineSegment(new Point(x: 2.0, y: 0.0), new Point(x: 4.0, y: 1.0)));
  segmentSet.add(new LineSegment(new Point(x: 2.0, y: 2.0), new Point(x: 2.0, y: 3.0)));
  
  test("test bentley_ottman: Multiple lines intersecting at point and vertical lines",
      () => expect(bentleyOttmanIntersections(segmentSet),
                   unorderedEquals([new Point(x: 2.0, y: 2.0),
                                    new Point(x: 3.3333333333333335, y: 0.6666666666666666),
                                    new Point(x: 3.3333333333333335, y:  3.3333333333333335)])));
}

void testSet4() {
  final segmentSet = new Set<LineSegment>();
  //Same as last dataset, but second segment has no length
  segmentSet.add(new LineSegment(new Point(x: 0.0, y: 0.0), new Point(x: 4.0, y: 4.0)));
  segmentSet.add(new LineSegment(new Point(x: 2.0, y: 2.0), new Point(x: 2.0, y: 2.0)));
  segmentSet.add(new LineSegment(new Point(x: 0.0, y: 4.0), new Point(x: 4.0, y: 0.0)));
  segmentSet.add(new LineSegment(new Point(x: 2.0, y: 4.0), new Point(x: 4.0, y: 3.0)));
  segmentSet.add(new LineSegment(new Point(x: 2.0, y: 0.0), new Point(x: 4.0, y: 1.0)));
  segmentSet.add(new LineSegment(new Point(x: 2.0, y: 2.0), new Point(x: 2.0, y: 3.0)));
  
  test("test bentley_ottman: Segment with zero length and multiple segments with same start",
      () => expect(bentleyOttmanIntersections(segmentSet),
                   unorderedEquals([new Point(x: 2.0, y: 2.0),
                                    new Point(x: 3.3333333333333335, y: 0.6666666666666666),
                                    new Point(x: 3.3333333333333335, y:  3.3333333333333335)])));
}

testSet5() {
  final segmentSet1 = new Set<LineSegment>();
  segmentSet1.add(new LineSegment(new Point(x: 0.0, y: 0.0), new Point(x: 1.0, y:1.0)));
  segmentSet1.add(new LineSegment(new Point(x: 1.0, y: 1.0), new Point(x: 2.0, y:1.0)));
  segmentSet1.add(new LineSegment(new Point(x: 1.0, y: 0.0), new Point(x: 0.0, y:1.0)));
  test("test bentley_ottmann: Ignore adjacent segments",
      () => expect(bentleyOttmanIntersections(segmentSet1, ignoreAdjacencies: true),
                   unorderedEquals([new Point(x: 0.5, y: 0.5)])));
}

testSet6() {
  final segmentSet = new Set<LineSegment>();
  segmentSet.add(new LineSegment(new Point(x: 0.0, y:0.0), new Point(x: 1.0, y: 1.0)));
  segmentSet.add(new LineSegment(new Point(x: 0.5, y:0.5), new Point(x: 1.5, y: 1.5)));
  test("test bentley_ottmann: Coincident segments",
      () => expect(bentleyOttmanIntersections(segmentSet),
                   unorderedEquals(
                       [new LineSegment(new Point(x:0.5, y:0.5), 
                                        new Point(x:1.0, y:1.0))]
  )));
}

void testSet7() {
  final segmentSet = new Set<LineSegment>();
  segmentSet.addAll([new LineSegment(new Point(x: 0.0, y: 0.0), new Point(x: 1.0, y: 1.0)), 
                     new LineSegment(new Point(x: 1.0, y: 1.0), new Point(x: 1.0, y: 0.0)), 
                     new LineSegment(new Point(x: 1.0, y: 0.0), new Point(x: 1.0, y: 0.0)), 
                     new LineSegment(new Point(x: 1.0, y: 0.0), new Point(x: 1.0, y: 1.0)), 
                     new LineSegment(new Point(x: 1.0, y: 1.0), new Point(x: 2.2, y: 2.2)), 
                     new LineSegment(new Point(x: 2.2, y: 2.2), new Point(x: 2.2, y: 2.2)), 
                     new LineSegment(new Point(x: 2.2, y: 2.2), new Point(x: 2.2, y: 2.2)), 
                     new LineSegment(new Point(x: 2.2, y: 2.2), new Point(x: 2.2000000000000104, y: 2.2)), 
                     new LineSegment(new Point(x: 2.2000000000000104, y: 2.2), new Point(x: 0.5, y: 1.0)), 
                     new LineSegment(new Point(x: 0.5, y: 1.0), new Point(x: 0.5, y: 1.0)), 
                     new LineSegment(new Point(x: 0.5, y: 1.0), new Point(x: 0.0, y: 0.0))]);
  
  //Probably the most pathological case we're likely to encounter.
  //It works here, it should work everywhere!
  test("test bentley_ottman: Multiple identical segments",
      () => expect(bentleyOttmanIntersections(segmentSet),
                   unorderedEquals([
                      new LineSegment(new Point(x: 1.0, y: 0.0), new Point(x: 1.0, y: 1.0)),
                      new Point(x: 0.0, y: 0.0),
                      new Point(x: 1.0, y: 1.0),
                      new Point(x: 2.2, y: 2.2),
                      new Point(x: 0.5, y: 1.0),
                      new Point(x: 1.0, y: 0.0),
                      new Point(x: 2.199999999999975, y: 2.199999999999975)]
  )));
}

void testSet8() {
  var segmentSet = new Set.from(
      [new LineSegment(new Point(x: 0.0, y: 0.0), new Point(x: 1.0, y: 1.0)),
       new LineSegment(new Point(x: 1.0, y: 1.0), new Point(x: 0.0, y: 0.0))
      ]);
  test("test_bentley_ottman: Reversed segment",
      () => expect(bentleyOttmanIntersections(segmentSet),
                   unorderedEquals([
                       new LineSegment(new Point(x: 0.0, y: 0.0), new Point(x:1.0, y: 1.0))
                   ])));
}