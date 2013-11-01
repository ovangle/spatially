library test_geometry_list;

import 'package:unittest/unittest.dart';

import 'package:spatially/geometry.dart';

import 'src/geometry/std_tests.dart';

void main() {
  testSimplify();
  
}

testSimplify() {
  final MultiGeometry geomList = new MultiGeometry();
  geomList.add(new Point(x: 0.0, y: 0.0));
  geomList.add(new LineSegment(new Point(x: -0.5, y: -0.5), new Point(x: 0.5, y: 0.5)));
  geomList.add(new LineSegment(new Point(x: 0.5, y: 0.5), new Point(x:0.5, y: 1.0)));
  final savList = geomList.simplify();
  print(savList);
  final expect1 = new MultiGeometry();
  expect1.add( new Linestring([ new Point(x:-0.5, y: -0.5), 
                                new Point(x: 0.5, y:0.5),
                                new Point(x: 0.5, y: 1.0) ]));
  test("test_geometry_list: simplify $geomList",
      () => expect(savList.simplify(), geometryEquals(expect1, 1e-15)));
  
  final MultiGeometry geomList2 = new MultiGeometry();
  geomList2.addAll([new Point(x: 2.0, y: 2.0),
                    new Point(x: 2.0, y: 2.0),
                    new Point(x: 3.33, y: 0.66),
                    new Point(x: 3.33, y: 0.66)]);
  final simple2 = geomList2.simplify();
  final expect2 = new MultiGeometry.from([new Point(x: 2.0, y:2.0), new Point(x: 3.33, y: 0.66)]);
  test("test_geometry_list: simplify $geomList2",
      () => expect(simple2, geometryEquals(expect2, 1e-15)));
  
  final MultiGeometry geomList3 = new MultiGeometry();
  geomList3.addAll([new LineSegment(new Point(x: 1.0, y: 0.0), new Point(x: 1.0, y: 1.0)),
                    new LineSegment(new Point(x: 1.0, y: 1.0), new Point(x: 1.0, y: 1.0)),
                    new LineSegment(new Point(x: 1.0, y: 1.0), new Point(x: 1.0, y: 0.0))]);
  final expect3 = new MultiGeometry.from(
      [new Linestring([ new Point(x: 1.0, y: 0.0), 
                        new Point(x: 1.0, y: 1.0), 
                        new Point(x: 1.0, y: 0.0)])
      ]);
  test("test_geometry_list: simplify $geomList3",
      () => expect(geomList3.simplify(), geometryEquals(expect3, 1e-15)));
  
}