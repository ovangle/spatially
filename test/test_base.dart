library test_base;

import 'package:unittest/unittest.dart';
import 'package:spatially/base.dart';

void main() {
  testArray();
}
/*
void testCoordinate() {
  group("Coordinate", () {
    test("Get ordinate", () {
      var coord = new Coordinate(1.0, 2.0, 3.0);
      expect(coord.getOrdinate(Coordinate.X), equals (1.0));
      expect(coord.getOrdinate(Coordinate.Y), equals(2.0));
      expect(coord.getOrdinate(Coordinate.Z), equals(3.0));
    });
    test("Coordinate.equals2d", () {
      var coord1 = new Coordinate(1.0, 2.0);
      var coord2 = new Coordinate(1.0, 2.0, 0.0);
      expect(coord1.equals2d(coord2), isTrue);
    });
    test("Coordinate.equals3d", () {
      var coord1 = new Coordinate(1.0, 2.0);
      var coord2 = new Coordinate(1.0, 2.0, double.NAN);
      expect(coord1.equals3d(coord2), isTrue);
    });
    
    test("Ordering of coordinates", () {
      expect(new Coordinate(1.0, 0.0) < new Coordinate(2.0, -1.0), isTrue);
      expect(new Coordinate(1.0, 0.0) > new Coordinate(0.0, 0.0), isTrue);
      expect(new Coordinate(1.0, 1.0) > new Coordinate(1.0, 0.0), isTrue);
    });
  });
}

void testCoordinateArray() {
  group("Coordinate Array", () {
    test("Remove repeated coordinates", () {
      var coords = new CoordinateArray.from(
          [new Coordinate.origin(),
           new Coordinate.origin(),
           new Coordinate(1.0, 1.0),
           new Coordinate(1.0, 1.0),
           new Coordinate(1.0, 1.0),
           new Coordinate(2.0, 1.0)]);
      var coords2 = new CoordinateArray.from(
          [new Coordinate.origin(),
           new Coordinate(1.0, 1.0),
           new Coordinate(2.0, 1.0)]);
      expect(coords.removeRepeatedCoordinates, equals(coords2));
    });
    test("Remove null coordinates", () {
      var coordArray = new CoordinateArray(5);
      coordArray[0] = new Coordinate.origin();
      var expected = new CoordinateArray.from([new Coordinate.origin()]);
      expect(coordArray.removeNulls, equals(expected));
    });
    test("Scroll coordinates", () {
      var coordArray = new CoordinateArray.from(
          [ new Coordinate.origin(),
            new Coordinate(1.0, 1.0),
            new Coordinate(2.0, 2.0)
          ]);
      coordArray.scroll(new Coordinate(1.0, 1.0));
      var expected = new CoordinateArray.from(
          [ new Coordinate(1.0, 1.0),
            new Coordinate(2.0, 2.0),
            new Coordinate.origin()
          ]);
    });
  });
}
*/

class IntArr extends Object with ArrayMixin<int> {
  Map<int, int> edited = new Map<int,int>();
  int operator [](int i) {
    if (edited.containsKey(i)) {
      return edited[i];
    }
    return i;
  }
  void operator []=(int i, int j) {
    edited[i] = j;
  }
  
  int get length => 500;
}

void testArray() {
  group("Array", () {
    test("swap elements", () {
      var arr = new IntArr();
      arr.swap(4, 5);
      expect(arr[4], equals(5));
      expect(arr[5], equals(4));
    });
    test("map function", () {
      var arr = new IntArr();
      var l = arr.map((x) => x + 1).toList();
      expect(l[0], equals(1));
      expect(l[10], equals(11));
    });
    test("reduce function", () {
      var arr = new IntArr();
      var sum = arr.reduce((e1, e2) => e1 + e2);
      expect(sum, equals(124750));
    });
  });
}



