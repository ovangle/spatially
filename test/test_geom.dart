library test_geom;

import 'package:unittest/unittest.dart';

import 'package:spatially/base.dart';
import 'package:spatially/geom/intersection_matrix.dart';
import 'package:spatially/geom/dimension.dart' as dim;

void main() {
  testIntersectionMatrix();
}

void testIntersectionMatrix() {
  group("Intersection matrix", () {
    final intersectionMatrix = new IntersectionMatrix();
    intersectionMatrix[0][0] = DIM_LINE;
    intersectionMatrix[1][0] = DIM_AREA;
    test("Matrix rows", () {
      final rows = new Array<Array<int>>.from([new Array<int>.from([DIM_LINE, DIM_EMPTY, DIM_EMPTY]),
                                               new Array<int>.from([DIM_AREA, DIM_EMPTY, DIM_EMPTY]),
                                               new Array<int>.from([DIM_EMPTY, DIM_EMPTY, DIM_EMPTY])]);
      expect(intersectionMatrix.rows, equals(rows));
    });
    test("Matrix columns", () {
      final cols = new Array<Array<int>>.from([new Array<int>.from([DIM_LINE, DIM_AREA, DIM_EMPTY]),
                                               new Array<int>.from([DIM_EMPTY, DIM_EMPTY, DIM_EMPTY]),
                                               new Array<int>.from([DIM_EMPTY, DIM_EMPTY, DIM_EMPTY])]);
      expect(intersectionMatrix.columns, equals(cols));
    });
  });
  test("Matrix from pattern", () {
    final fromPattern = new IntersectionMatrix.fromPattern("11F222012");
    final expectMatrix = new IntersectionMatrix();
    expectMatrix.rows = new Array<Array<int>>.from([new Array<int>.from([DIM_LINE, DIM_LINE, DIM_EMPTY]),
                                                    new Array<int>.from([DIM_AREA, DIM_AREA, DIM_AREA]),
                                                    new Array<int>.from([DIM_POINT, DIM_LINE, DIM_AREA])]);
    expect(fromPattern, equals(expectMatrix));
  });
  test("Matrix matches", () {
    final dimPattern = new IntersectionMatrix.fromPattern("11F222012");
    final matchPattern = "1TF**2012";
    expect(dimPattern.matches(matchPattern), isTrue);
  });
}