/**
 * Various fundamental computational geometric algorithms.
 */
library algorithm.cg_algorithms;

import 'dart:math' as math;

import 'package:range/range.dart';

import 'package:spatially/base/array.dart';
import 'package:spatially/base/coordinate.dart';
import 'package:spatially/geom/location.dart' as location;

import 'cg_algorithms_ld.dart' as cg_algorithms_ld;



/**
 * A clockwise, or right turn
 */
const int CLOCKWISE = -1;

/**
 * A clockwise, or right turn
 */
const int RIGHT = CLOCKWISE;

/**
  * A counterclockwise, or left turn
  */
const int COUNTERCLOCKWISE = 1;

/**
 * A counterclockwise, or left turn
 */
const int LEFT = COUNTERCLOCKWISE;

/**
 * Collinear points, or straight turn
 */
const int COLLINEAR = 0;

/**
 * Collinear points, or straight turn
 */
const int STRAIGHT = COLLINEAR;

/**
 * The index of the direction of the point [:q:] relative
 * to the vector defined by [:c1:] -> [:c2:]
 * 
 * Returns 
 * `1` if the point is counter-clockwise (left) of [:c1:]->[:c2:]
 * `-1` if the point is clockwise (right) of [:c1:]->[:c2:]
 * `0` if the point is collinear with [:c1:]->[:c2:]
 */
//FIXME: See comment in CGAlgorithms.orentiationIndex.
//       This algorithm fails for some coordinates.
//       Should be alright for the moment.
int orientationIndex(Coordinate c1, Coordinate c2, Coordinate q) =>
    cg_algorithms_ld.orientationIndex(c1, c2, q);

/**
 * Tests wether the point lies inside or on a ring. The ring may
 * be oriented in either direction. A point lying on the ring boundary
 * is considered to be inside the ring.
 */
bool isPointInRing(Coordinate c, Array<Coordinate> ring) {
  return locatePointInRing(c, ring) != location.EXTERIOR;
}

/**
 * Returns the location value of the point relative to the ring
 * The ring may be oriented in either direction.
 */
int locatePointInRing(Coordinate c, Array<Coordinate> ring) {
  //TODO: Implement this
  throw 'NotImplemented';
}

/**
 * Tests whether a point lies on any of the line segments defined
 * by a list of coordinates
 */
bool isOnLine(Coordinate c, Array<Coordinate> coords) {
  throw 'NotImplemented';
}

/**
 * Determines whether a ring defined by an array of coordinates
 * is oriented counter-clockwise.
 * 
 * The list of points is assumed to have the first and last points equal.
 * The method is only guaranteed for a ring which doesn't self intersect
 */
bool isCounterClockwise(Array<Coordinate> ring) {
  int numPoints = ring.length - 1;
  if (numPoints < 3) {
    throw new ArgumentError("Ring has too few coordinates");
  }
  Coordinate highCoord =
      ring.fold(
          new Coordinate(double.NEGATIVE_INFINITY, double.NEGATIVE_INFINITY),
          (hi, c) => (c.y >= hi.y) ? c : hi); 
  int hiCoordAt = ring.indexOf(highCoord);
  
  //Previous distinct point before hiCoord
  int iPrev = hiCoordAt;
  do {
    iPrev = (iPrev - 1) % numPoints;
  } while (ring[iPrev] == highCoord && iPrev != hiCoordAt);

  //Next distinct point after hiCoord
  int iNext = hiCoordAt;
  do {
    iNext = (iNext + 1) % numPoints;
  } while (ring[iNext] == highCoord && iNext != hiCoordAt);
  
  var prev = ring[iPrev];
  var next = ring[iNext];
  
  /*
   * Check whether the ring contains an A-B-A configuration of 
   * pojnts. This can happen if it contains coincident line segments
   */
  if (prev == highCoord || next == highCoord || prev == next) {
    return false;
  }
  
  int orientation = orientationIndex(prev, highCoord, next);

  if (orientation == 0) {
    //The three points are collinear.
    //If prev is to the right of next, the ring must be counterclockwise
    return prev.x > next.x;
  }
  return orientation == COUNTERCLOCKWISE;
}

/**
 * Computes the distance from a [Coordinate] to the
 * line segment defined from [:a:] to [:b:]
 */
double distanceToLine(Coordinate c, Coordinate A, Coordinate B) {
  if (A == B) {
    return c.distance(A);
  }
  
  // l = || AB ||^2
  var lenSqr = A.distanceSqr(B);
  // r = (AC . AB) / (l)
  var ac_dot_ab = (c.x - A.x) * (B.x - A.x)
                + (c.y - A.y) * (B.y - A.y);
  var r = ac_dot_ab / lenSqr;
  if (r <= 0.0) {
    //Point is on the backward extension of AB
    return c.distance(A);
  }
  if (r >= 1.0) {
    //Point is on forward extension of AB
    return c.distance(B);
  }
  
  return perpendicularDistanceToLine(c, A, B);
}

/**
 * The perpendicular distance from the coordinate [:c:]
 * to the infinite line passing through AB
 * It is assumed that A != B
 */
double perpendicularDistanceToLine(Coordinate c, Coordinate A, Coordinate B) {
  // l = || AB ||^2
  var lenSqr = A.distanceSqr(c);
  
  // s = (Ay - Cy)(Bx - Ax) - (Ax - Cx)(By - Ay)
  //     ---------------------------------------
  //                        l
  var s = (A.y - c.y) * (B.x - A.x)
        - (A.x - c.x) * (B.y - A.y); 
  s /= lenSqr;
  
  // The distance to c is |s|*l
  return s.abs() * math.sqrt(lenSqr);
}

/**
 * The minimum distance from a point to a sequence of lines
 * line segments
 */
double pointToLineDistance(Coordinate c, Array<Coordinate> line) {
  if (line.isEmpty) {
    throw new ArgumentError("line cannot be empty");
  }
  var minDist = c.distance(line[0]);
  for (var i in range(1, line.length)) {
    double dist = distanceToLine(c, line[i - 1], line[i]);
    minDist = (dist < minDist) ? dist : minDist;
  }
  return minDist;
}

/**
 * Calculates the distance between the line segment A->B
 * and the line segment C->D
 */
double lineToLineDistance(Coordinate A, Coordinate B, 
                          Coordinate C, Coordinate D) {
  if (A == B) return distanceToLine(A, C, D);
  if (C == D) return distanceToLine(D, A, B);
  
  //The distance if the lines don't intersect
  //Is the minimum distance from any endpoint
  //to the other line
  double distNoIntersection() {
    var distances = [ distanceToLine(A, C, D),
                      distanceToLine(B, C, D),
                      distanceToLine(C, A, B),
                      distanceToLine(D, A, B) ];
    return distances.fold(double.INFINITY, math.min);
  }
  
  // d = (B.x - A.x)(D.y - C.y) - (B.y - A.y)(D.x - C.x)
  final d = (B.x - A.x) * (D.y - C.y) - (B.y - A.y) * (D.x - C.x);
  
  // If d == 0, AB is parallel to CD
  if (d == 0) 
    return distNoIntersection();
  
  
  // r = (A.y - C.y)(D.x - C.x) - (A.x - C.x)(D.y - C.y)
  //     -----------------------------------------------
  //                            d
  
  final r1 = (A.y - C.y) * (D.x - C.x) - (A.x - C.x) * (D.y - C.y); 
  final r = r1 / d;
  
  // s = (A.y - C.y)(B.x - A.x) - (A.x - C.x)(B.y - A.y)
  //     -----------------------------------------------
  //                            d
  
  final s1 = (A.y - C.y) * (B.x - A.x) - (A.x - C.x) * (B.x - A.y);
  final s = s1 / d;  
  
  // If 0 <= r <= 1 && 0 <= s <= 1, AB intersects CD
  // Otherwise, no intersection
  
  if (r < 0 || r > 1 || s < 0 || s > 1) {
    return distNoIntersection();
  }
  return 0.0;
}

/**
 * Computes the signed area of the ring.
 * 
 * The signed area is:
 * positive if the ring is oriented clockwise
 * 0 if the ring is degenerate
 * negative if the ring is oriented counter-clockwise
 * 
 * Based on the [shoelace formula]
 * (http://en.wikipedia.org/wiki/Shoelace_formula)
 */
double signedAreaOfRing(Array<Coordinate> ring) {
  if (ring.length == 0) return 0.0;
  if (ring.length <= 3) {
    throw new ArgumentError("Ring must have >= 4 vertices");
  }
  var sum = 0.0;
  var x0 = ring.first.x;
  for (var i in range(1, ring.length - 1)) {
    var x = ring[i].x - x0;
    var y1 = ring[i + 1].y;
    var y2 = ring[i - 1].y;
    sum += x * (y2 - y1);
  }
  return sum / 2.0;
}

/**
 * Returns the length of a linestring specified
 * by a sequence of points
 */
double linestringLength(Array<Coordinate> line) {
  if (line.length <= 1) {
    return 0.0;
  } else {
    return range(1, line.length)
        .fold(0.0, (t, i) => t + line[i-1].distance(line[i]));
  }
}