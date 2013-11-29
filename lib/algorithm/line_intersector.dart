library algorithm.line_intersector;

import 'package:spatially/base/coordinate.dart';
import 'package:spatially/base/envelope.dart';
import 'package:spatially/base/line_segment.dart';
import 'package:spatially/algorithm/cg_algorithms.dart' as cg_algorithms;

/**
 * The result of intersecting the given [LineSegment]
 * with a [Coordinate]. Returns the coordinate if it intersects
 * the line segment, otherwise returns `null`.
 */
Coordinate coordinateIntersection(LineSegment lseg, Coordinate c) {
  if (lseg.envelope.intersectsCoordinate(c)) {
    if (cg_algorithms.orientationIndex(lseg, c) == 0
        && cg_algorithms.orientationIndex(lseg.reversed, c) == 0) {
      return c;
    }
  }
  return null;
}

/**
 * Check if the intersection of [:lseg1:] and [:lseg2:] is proper.
 * An intersection is proper if it lies entirely within
 * the interior of both the argument [LineSegment]s.
 * 
 * [:intersectionResult:] is an optional argument with the result
 * of intersecting the arguments unsing [segmentIntersection].
 * Providing it will prevent recalculating the intersection, to 
 * improve efficiency
 */
bool isProperIntersection(LineSegment lseg1, 
                          LineSegment lseg2, 
                          [dynamic /* Coordinate | LineSegment */intersectionResult = 0 ]) {
  if (intersectionResult == 0) {
    //We can't use null as the default argument
    //because `null` is a valid value for the intersection
    //of the two linesegments
    intersectionResult = segmentIntersection(lseg1, lseg2);
  }
  if (intersectionResult is! Coordinate) {
    //Collinear intersections must always contain at least one of the endpoints
    //If there is no intersection, it can't be proper
    return false;
  }
  Coordinate coord = intersectionResult as Coordinate;
  return coord != lseg1.start
      && coord != lseg1.end
      && coord != lseg2.start
      && coord != lseg2.end;
}

/**
 * Returns the result of intersecting two segments. 
 * The result will be:
 * A [Coordinate], if the segments intersect at a single point.
 * A [LineSegment], if the segments intersect along a non-degenerate
 * line segment.
 * `null`, if the segments do not intersect.
 */
dynamic /* Point | LineSegment */ segmentIntersection(LineSegment lseg1, LineSegment lseg2) {
  //If the envelopes don't intersect, neither do the segments
  if (!lseg1.envelope.intersectsEnvelope(lseg2.envelope)) {
    return null;
  }
  
  //Compare the orientations of both endpoints of the 
  //segments to the other segment.
  //If both the endpoints lie on the same side of the other
  //segment, then the lines don't intersect.
  
  final lseg1ToStart = cg_algorithms.orientationIndex(lseg1, lseg2.start);
  final lseg1ToEnd   = cg_algorithms.orientationIndex(lseg1, lseg2.end);
  
  if (lseg1ToStart > 0 && lseg1ToEnd > 0
      || lseg1ToStart < 0 && lseg1ToEnd < 0) {
    return null;
  }
  
  final lseg2ToStart = cg_algorithms.orientationIndex(lseg2, lseg1.start);
  final lseg2ToEnd   = cg_algorithms.orientationIndex(lseg2, lseg1.end);

  if (lseg2ToStart > 0 && lseg2ToEnd > 0
      || lseg2ToStart < 0 && lseg2ToEnd < 0) {
    return null;
  }
  
  if (lseg1ToStart == 0 
      && lseg1ToEnd == 0
      && lseg2ToStart == 0
      && lseg2ToEnd == 0) {
    return _collinearIntersection(lseg1, lseg2);
  }
  
  //The segments aren't intersecting,
  //so the result must be a point intersection
  Coordinate intersectionCoord = null;
  
  //Check explicitly for equal endpoints
  if (lseg1.start == lseg2.start
      || lseg1.start == lseg2.end) {
    intersectionCoord = lseg1.start;
  }
  
  if (lseg1.end == lseg2.start
      || lseg1.end == lseg2.end) {
    intersectionCoord = lseg1.end;
  }
  
  if (lseg1ToStart == 0) {
    intersectionCoord = lseg2.start;
  } else if (lseg1ToEnd == 0) {
    intersectionCoord = lseg2.end;
  } else if (lseg2ToStart == 0) {
    intersectionCoord = lseg1.start;
  } else if (lseg2ToEnd == 0) {
    intersectionCoord = lseg1.end;
  }
  
  
  if (intersectionCoord == null) {
    intersectionCoord = _computeIntersectionNormalized(lseg1, lseg2); 
  }
  return intersectionCoord;
}

dynamic /*Coordinate | LineSegment */ _collinearIntersection(LineSegment lseg1, LineSegment lseg2) {
  /**
   * Test whether the start of a is in the envelope of b
   */
  bool inEnvelopeOf(Coordinate a, LineSegment b) =>
      b.envelope.intersectsCoordinate(a);
  
  Set<Coordinate> coords = new Set<Coordinate>();
  
  if (inEnvelopeOf(lseg1.start, lseg2)) {
    coords.add(lseg1.start);
  }
  if (inEnvelopeOf(lseg1.end, lseg2)) {
    coords.add(lseg1.end);
  }
  if (inEnvelopeOf(lseg2.start, lseg1)) {
    coords.add(lseg2.start);
  }
  if (inEnvelopeOf(lseg2.end, lseg1)) {
    coords.add(lseg2.end);
  }
  
  switch (coords.length) {
    case 0: 
      return null;
    case 1: 
      return coords.single;
    case 2: 
      List<Coordinate> sorted = new List.from(coords)
                  ..sort();
      return new LineSegment(sorted.first, sorted.last);
    default:
      print("Too many coordinates in collinear intersection:\n"
            "\tlseg1: $lseg1\n"
            "\tlseg2: $lseg2\n");
      assert(false);
  }
  
}

/**
 * Computes the intersection of the line segments, 
 * normalizing by translating the segments so that the
 * intersection of their envelopes lies at the origin
 * to improve precision.
 */
Coordinate _computeIntersectionNormalized(LineSegment lseg1, LineSegment lseg2) {
  Map normalization = _normalizeSegments(lseg1, lseg2);
  var normalCoord = normalization["normal_coord"];
  var coord = _computeIntersection(normalization["lseg1"], normalization["lseg2"]);
  coord = coord.translated(normalCoord.x, normalCoord.y);
  return coord;
}

/**
 * Computes the intersection of the two linesegment.
 * This method assumes that the segments intersect
 * at a single point which is not contained with any
 * point in the intersection.
 */
Coordinate _computeIntersection(LineSegment lseg1, 
                                LineSegment lseg2) {
  final w1 = lseg1.start.x * lseg1.end.y - lseg1.end.x * lseg1.start.y;
  final w2 = lseg2.start.x * lseg2.end.y - lseg2.end.x * lseg2.start.y;
  final w = lseg1.dx * lseg2.dy - lseg2.dx * lseg1.dy;
  
  final x = (lseg1.dx * w2 - lseg2.dx * w1) / w;
  final y = (lseg1.dy * w2 - lseg2.dy * w1) / w;
  
  return new Coordinate(x, y);
}

/**
 * Normalize the line segments so that the center of the 
 * intersection of their envelopes lies at the origin
 * 
 * Returns a map, with keys:
 *  -- "normal_coord" : The coordinate used to normalise the segments
 *  -- "lseg1" : The normalized lseg1
 *  -- "lseg2" : The normalized lseg2  
 */
Map _normalizeSegments(LineSegment lseg1, LineSegment lseg2) {
  Envelope env1 = lseg1.envelope;
  Envelope env2 = lseg2.envelope;
  Envelope envIntersection = env1.intersection(env2);
  
  Coordinate normalCoord = envIntersection.centre;
  return { "normal_coord" : normalCoord,
           "lseg1" : lseg1.translated(-normalCoord.x, -normalCoord.y),
           "lseg2" : lseg2.translated(-normalCoord.x, -normalCoord.y) };
}