library base.line_segment;

import 'dart:math' as math;
import 'package:quiver/iterables.dart';
import 'package:spatially/algorithm/cg_algorithms.dart' as cg_algorithms;
import 'package:spatially/algorithm/line_intersector.dart' as li;

import 'coordinate.dart';
import 'envelope.dart';

/**
 * Returns an iterable over all the [LineSegment]s obtained between
 * adjacent coordinate pairs in a list of coordinates.
 */
Iterable<LineSegment> coordinateSegments(Iterable<Coordinate> coords) {
  List<Coordinate> coordList = coords.toList();
  return range(1, coords.length)
        .map((i) => new LineSegment(coordList[i - 1], coordList[i]));
}
/**
 * Represents the [LineSegment] between two [Coordinate]s
 */
class LineSegment {

  /**
   * The [LineSegment] is in the [NORTH_EAST] quadrant
   * if `dx >= 0` and `dy >= 0`.
   */
  static const int NORTH_EAST = 0;
  /**
   * A [LineSegment] is in the [NORTH_WEST] quadrant
   * if `dx < 0` and `dy >= 0`.
   */
  static const int NORTH_WEST = 1;
  /**
   * A [LineSegment] is in the [SOUTH_EAST] quadrant
   * if `dx < 0` and `dy < 0`.
   */
  static const int SOUTH_EAST = 2;
  /**
   * A [LineSegment] is in the [SOUTH_WEST] quadrant
   * if `dx >= 0` and `dy < 0`.
   */
  static const int SOUTH_WEST = 3;


  final Coordinate start;
  final Coordinate end;

  LineSegment(Coordinate this.start, Coordinate this.end);

  Envelope get envelope =>
      new Envelope.fromCoordinates(start, end);

  /**
   * The extent of the [LineSegment] along the x-axis
   * Equivalent to end.x - start.x
   */
  double get dx => end.x - start.x;
  /**
   * The extent of the [LineSegment] along the y-axis.
   * Equivalent to end.y - start.y
   */
  double get dy => end.y - start.y;

  /**
   * The [quadrant] of a [LineSegment] represents the
   * section of the plane towards which the line segment
   * is directed.
   * The quadrants are numbered in an anti-clockwise
   * fashion around the origin, with the north east quadrant
   * numbered `0` and the south east quadrant numbered `3`.
   */
  int get quadrant {
    if (dy >= 0) {
      return (dx >= 0) ? NORTH_EAST : NORTH_WEST;
    } else {
      return (dx >= 0) ? SOUTH_EAST : SOUTH_WEST;
    }
  }

  /**
   * The index of the direction of the point [:q:] relative
   * to the vector defined by [:c1:] -> [:c2:]

   * Returns
   * `1` if the point is counter-clockwise (left) of [:c1:]->[:c2:]
   * `-1` if the point is clockwise (right) of [:c1:]->[:c2:]
   * `0` if the point is collinear with [:c1:]->[:c2:]
   */
  int orientationIndex(Coordinate c) =>
      cg_algorithms.orientationIndex(this, c);

  /**
   * Determines whether a [Coordinate] lies on the
   * line segment.
   */
  bool isCoordinateOn(Coordinate c) =>
      li.coordinateIntersection(this, c) != null;

  /**
   * Calculates the distance to the given coordinate.
   */
  double distanceToCoordinate(Coordinate c) =>
      cg_algorithms.distanceToLine(c, this);

  /**
   * Calculates the distance to the given line segment.
   */
  double distanceToSegment(LineSegment lseg) =>
      cg_algorithms.lineToLineDistance(this, lseg);
  /**
   * Returns the result of intersecting two segments.

   * The result will be:
   *  A [Coordinate], if the segments intersect at a single point.
   *  A [LineSegment], if the segments intersect along a non-degenerate
   *  line segment.
   *  `null`, if the segments do not intersect.
   */
  dynamic /*LineSegment | Coordinate */ segmentIntersection(LineSegment lseg) =>
      li.segmentIntersection(this, lseg);

  /**
   * Returns the coordinate if it intersects `this`, otherwise `null`.
   */
  Coordinate coordinateIntersection(Coordinate c) =>
      li.coordinateIntersection(this, c);

  /**
   * The angle that this [LineSegment] makes with the
   * positive x-axis, as a [double] in the range (-PI,PI]
   */
  double get angle =>
      math.atan2(dy, dx);

  /**
   * A [LineSegment] from [end] to [start].
   */
  LineSegment get reversed =>
      new LineSegment(end, start);

  /**
   * A new [LineSegment] translated by [:dx:] along the
   * x-axis and [:dy:] units along the y-axis
   */
  LineSegment translated(double dx, double dy) =>
      new LineSegment(start.translated(dx, dy),
                      end.translated(dx, dy));

  bool equals2d(LineSegment lseg, [tolerance=0.0]) =>
      start.equals2d(lseg.start, tolerance = tolerance)
      && end.equals2d(lseg.end, tolerance = tolerance);

  bool equals3d(LineSegment lseg) =>
      start.equals3d(lseg.start)
      && end.equals3d(lseg.end);

  bool operator ==(Object o) {
    if (o is LineSegment) {
      return equals2d(o);
    }
    return false;
  }

  int get hashCode =>
      [start,end].fold(17, (h, c) => h + c.hashCode);

  String toString() =>
      "$start -> $end";
}

