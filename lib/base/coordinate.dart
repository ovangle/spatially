library base.coordinate;

import 'dart:math' as math;

import 'package:quiver/iterables.dart';

part 'src/coordinate/coordinate_array.dart';

/**
  * A [Coordinate] represents a single location in the 2d cartesian plane
  * Unlike [Point] objects, which contain additional information such as
  * the envelope, precision model and spatial reference system information
  * a [Coordinate] contains only ordinate values and accessor methods.
  *
  * [Coordinate]s are two dimensional points, with an additional Z-ordinate.
  * spatially does not support any operations on the Z-ordinate except the
  * basic accessor functions.
  *
  * If a Z-ordinate is not specified or not defined, constructed coordinates
  * have a Z-ordinate of `NaN`
  *
  * The standard comparison functions ignore the Z-ordinate
  */
class Coordinate implements Comparable<Coordinate> {
  static const NULL_ORDINATE = double.NAN;

  /**
   * Standard ordinate index values
   */
  static const int X = 0;
  static const int Y = 1;
  static const int Z = 2;
  static const int M = 3;

  double x;
  double y;
  double z;
  double m;

  /**
   * Constructs a [Coordinate] at (x, y, z, m)
   */
  Coordinate(num x, num y, [num z = double.NAN, num m = double.NAN]) :
    this.x = x.toDouble(),
    this.y = y.toDouble(),
    this.z = z.toDouble(),
    this.m = m.toDouble();

  /**
   * Constructs a [Coordinate] at (0.0, 0.0, NaN, NaN)
   */
  Coordinate.origin() : this(0.0, 0.0);

  /**
   * Creates a copy of the specified [Coordinate]
   */
  Coordinate.copy(Coordinate c) : this(c.x, c.y, c.z, c.m);

  Coordinate.fromPoint(math.Point p) : this(p.x, p.y);

  bool get is2d => z.isNaN;

  /**
   * Get the [Coordinate] for the given index.
   * Throws an [ArgumentError] if the index is not valid
   */
  double getOrdinate(int index) {
    switch(index) {
      case X: return x;
      case Y: return y;
      case Z: return z;
      case M: return m;
      throw new ArgumentError("Invalid ordinate index: $index");
    }
  }

  /**
   * Set the ordinate at the given index.
   * Throws an [ArgumentError] if the index is not valid.
   */
  void setOrdinate(int index, double value) {
    switch(index) {
      case X:
        this.x = value;
        return;
      case Y:
        this.y = value;
        return;
      case Z:
        this.z = value;
        return;
      case M:
        this.m = value;
        return;
      default:
        throw new ArgumentError ("Invalid ordinate index: $index");
    }
  }

  /**
   * Determines whether the planar projections of the two [Coordinate]s
   * are equal, or if [:other:] lies in a disc around `this` of
   * radius [:tolerance:]
   */
  bool equals2d(Coordinate other, [double tolerance = 0.0]) {
    if (tolerance == 0.0) {
      return x == other.x && y == other.y;
    }
    return distance(other) <= tolerance;
  }

  /**
   * Determines whether the two [Coordinate]s have the same values for
   * [:x:], [:y:] and [:z:]
   */
  bool equals3d(Coordinate other) =>
      equals2d(other) && z == other.z || (z.isNaN && other.z.isNaN);

  /**
   * Returns `true` if [:other:] has the same values for the [:x:]
   * and [:y:] ordinates.
   * Ignores the [:z:] value when making the comparison
   */
  bool operator ==(Object other) =>
      other is Coordinate && equals2d(other);

  /**
   * Comparison relations using the default, lexicographical ordering
   * on [Coordinate]s
   */
  bool operator <(Coordinate c) => compareTo(c) < 0;
  bool operator >(Coordinate c) => compareTo(c) > 0;
  bool operator <=(Coordinate c) => compareTo(c) <= 0;
  bool operator >=(Coordinate c) => compareTo(c) >= 0;

  /**
   * The [:hashCode:] of the coordinate
   */
  int get hashCode => [x, y].fold(37, (h, ord) => h * 37 + ord.hashCode);

  /**
   * Compares this [Coordinate] with the specified [Coordinate] for order
   * Ignores the z value
   * Returns:
   * -- -1 iff this.x < other.x || (this.x == other.x && this.y < other.y)
   * -- 0 iff this.x == other.x && this.y == other.y
   * -- 1 iff this.x > other.x && (this.x == other.x && this.y < other.y)
   *
   * Assumes ordinate values are valid numbers. NaNs are not handled correctly.
   *
   * If [:comparator:] is provided and not null, the comparator is used
   * to perform the comparison
   */
  int compareTo(Coordinate c, [Comparator<Coordinate> comparator]) {
    if (comparator == null) {
      var cmpx = Comparable.compare(x, c.x);
      return cmpx != 0 ? cmpx : Comparable.compare(y, c.y);
    }
    return comparator(this, c);
  }

  /**
   * A new [Coordinate], translated along the x-axis by dx
   * and along the y-axis by dy
   */
  Coordinate translated(double dx, double dy) =>
      new Coordinate(x + dx, y + dy);

  /**
   * A string representation of the [Coordinate] in the form (x, y, z)
   */
  String toString() => "($x, $y)";

  math.Point<num> toPoint() => new math.Point<num>(x, y);

  /**
   * Return the square of the distance to another
   * coordinate. The Z-ordinate is ignored
   */
  double distanceSqr(Coordinate c) {
    final dx = x - c.x;
    final dy = y - c.y;
    return dx * dx + dy * dy;
  }

  /**
   * The 2-dimensional euclidean distance to another [Coordinate].
   * The Z-ordinate is ignored
   */
  double distance(Coordinate c) => math.sqrt(distanceSqr(c));
}

/**
 * Returns a function which accepts two [Coordinates] and compares
 * their ordinates in either `2` or `3` dimensions.
 */
Comparator<Coordinate> dimensionalComparator([int dimensionsToTest = 2]) {
  if (dimensionsToTest != 2 && dimensionsToTest != 3) {
    throw new ArgumentError("Only 2 or 3 dimensions may be specified");
  }
  int compare(Coordinate c1, Coordinate c2) {
    int cmpX = c1.x.compareTo(c2.x);
    if (cmpX != 0) return cmpX;

    int cmpY = c1.x.compareTo(c2.x);
    if (cmpY != 0) return cmpY;

    if (dimensionsToTest <= 2) return 0;

    int cmpZ = c1.z.compareTo(c2.z);
    if (cmpZ != 0) return cmpZ;
  }
  return compare;
}