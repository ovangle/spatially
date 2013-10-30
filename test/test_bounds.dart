library test_bounds;

import 'package:spatially/geometry.dart';
import 'package:unittest/unittest.dart';

import 'geometry_tests.dart';

void main() {
  testConstructors();
  testSize();
  testScale();
  testTranslate();
  testWrapDateLine();
  testContains();
  testEncloses();
}

final unitBounds = new Bounds(bottom: 0.0, top: 1.0, left: 0.0, right: 1.0);

void testConstructors() {
  final topEast = new Point(y: 43.25, x: 43.25);
  final bottomWest = new Point(y: 23.44, x: 34.88);
  
  final bounds = new Bounds.fromDiagonal(
      bottomLeft: bottomWest, 
      topRight: topEast);
  
  test("test_bounds: new Bounds.fromDiagonal == new Bounds",
      () => expect(bounds,
                   equals(new Bounds(bottom: 23.44, top: 43.25,
                                     right: 43.25, left: 34.88))));
 
  test("test_bounds: directional getters",
       () => expect([bounds.top, bounds.bottom, bounds.right, bounds.left],
                    equals([43.25, 23.44, 43.25, 34.88])));
}

testSize() {
  final bounds = new Bounds(bottom: 0.0, top: 1.0, left: 0.0, right:1.0);
  test("test_bounds: Width is 1.0",
       () => expect(bounds.width, equals(1.0)));
  test("test_bounds: Height is 1.0",
      () => expect(bounds.height, equals(1.0)));
  test("test_bounds: Center is at <0.5, 0.5>",
      () => expect(bounds.center, equals(new Point(y: 0.5, x: 0.5))));
}

testScale() {
  test("test_bounds: Scaling unit bounds by 2x around topEast",
      () => expect(unitBounds.scale(2.0, origin: unitBounds.topRight),
                   equals(new Bounds(bottom: -1.0, top: 1.0, left: -1.0, right: 1.0))));
  test("test_bounds: Scaling unit bounds by 2x around bottomWest",
      () => expect(unitBounds.scale(2.0, origin: unitBounds.bottomLeft),
                   equals(new Bounds(bottom: 0.0, top: 2.0, left: 0.0, right: 2.0 ))));
  test("test_bounds: Scaling unit bounds by 2x around center",
      () => expect(unitBounds.scale(2.0),
                   equals(new Bounds(bottom:-0.5, top: 1.5, left: -0.5, right: 1.5))));
  test("test_bounds: Scaling unit bounds by 2x around <0.25, 0.25>",
      () => expect(unitBounds.scale(2.0, origin: new Point(x: 0.25, y: 0.25)),
                   equals(new Bounds(bottom: -0.25, top: 1.75, left: -0.25, right: 1.75))));
  test("test_bounds: Scaling unit bounds by 2x around <-1, -1>",
      () => expect(unitBounds.scale(2.0, origin: new Point(x: -1.0, y: -1.0)),
                  equals(new Bounds(bottom: 1.0, top: 3.0, left: 1.0, right: 3.0))));
}

testTranslate() {
  test("test_bounds: Tranlate unit bounds by 1.0 to bottom",
      () => expect(unitBounds.translate(dy: -1.0),
                   equals(new Bounds(bottom: -1.0, top: 0.0, left:0.0, right: 1.0))));
  test("test_bounds: Transye unit boudns by 1.0 to right",
      () => expect(unitBounds.translate(dx: 1.0),
                   equals(new Bounds(bottom:0.0, top: 1.0, left: 1.0, right: 2.0))));
  test("test_bounds: Transye unit bounds by 1.0 to left",
      () => expect(unitBounds.translate(dx: -1.0),
                   equals(new Bounds(bottom:0.0, top: 1.0, left: -1.0, right: 0.0))));
}

testWrapDateLine() {
  var worldBounds = new Bounds(bottom: 0.0, top: 1.0, left: 0.0, right: 1.0);
  var bounds = new Bounds(bottom: 0.25, top: 1.25, left: -0.5, right: -0.25);
  test("test_bounds: $bounds wrapped to world bounds $worldBounds"
       " (entirely outside bounds)",
      () => expect(bounds.wrapDateLine(worldBounds),
                   equals(new Bounds(bottom: 0.25, top: 1.25, left: 0.5, right: 0.75))));
  
  var bounds2 = new Bounds(bottom: 0.25, top: 1.25, left: -1.1, right: -0.9);
  test("test_bounds: $bounds2 wrapped to world bounds $worldBounds"
      " (crosses left extent)", () {
    final wrappedBounds = new Bounds(bottom: 0.25, top: 1.25, left:-0.1, right: 0.1);
    expect(bounds2.wrapDateLine(worldBounds),
           boundsCloseTo(wrappedBounds, 1e-15));
  });
  
  var bounds3 = new Bounds(bottom: 0.25, top: 1.25, left: 0.9, right: 1.1);
  test("test_bounsd: $bounds3 wrapped to world bounds $worldBounds"
       " (crosses right extent)", () {
    final wrappedBounds = new Bounds(bottom: 0.25, top: 1.25, left: -0.1, right:0.1);
    expect(bounds3.wrapDateLine(worldBounds),
           boundsCloseTo(wrappedBounds, 1e-15));
  });
}

testExtend() {
  test("test_bounds: Extend unit bounds to <2.0, 2.0>",
      () => expect(unitBounds.extend(new Point(y:2.0, x:2.0)),
                   equals(new Bounds(bottom: 0.0, top: 2.0, left:0.0, right:2.0))));
  test("test_bounds: Extend unit bounds to contain Bounds(bottom: -4.0, top:4.0, left:-4.0, right:4.0",
      () => expect(unitBounds.extend(new Bounds(bottom:-4.0, top:4.0, left:-4.0, right:4.0)),
                  equals(new Bounds(bottom: -4.0, top: 4.0, left: -4.0, right: 4.0))));
  }

testContains() {
  test("test_bounds: Unit bounds contains centre",
      () => expect(unitBounds.enclosesPoint(unitBounds.center), isTrue));
}

testEncloses() {
  test("Bounds(<-1.0,-1.0>, <1.0,1.0>) encloses unit bounds",
       () => expect(new Bounds(bottom:-1.0, top: 1.0, left:-1.0, right:1.0).encloses(unitBounds), isTrue));
}