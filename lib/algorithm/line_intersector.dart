library algorithm.line_intersector;

import 'package:spatially/base/coordinate.dart';
import 'package:spatially/base/envelope.dart';
import 'package:spatially/base/line_segment.dart';
import 'package:spatially/algorithm/cg_algorithms.dart' as cg_algorithms;

/** The segments do not intersect */
const int NO_INTERSECTION         = 0;
/* The segments intersect at a single point */
const int POINT_INTERSECTION      = 1;
/** The segments intersect at a line segment */
const int COLLINEAR_INTERSECTION  = 2;

/**
 * The result of intersecting the given [LineSegment]
 * with a [Coordinate]
 */
int coordinateIntersection(LineSegment lseg, Coordinate c) {
  if (lseg.envelope.intersectsCoordinate(c)) {
    if (cg_algorithms.orientationIndex(lseg, c) == 0
        && cg_algorithms.orientationIndex(lseg.reversed, c) == 0) {
      
      if (lseg.start ==c || lseg.end == c) {
        return POINT_INTERSECTION;
      }
      
    }
  }
  return NO_INTERSECTION;
}

Map segmentIntersection(LineSegment lseg1, LineSegment lseg2) {
  //If the envelopes don't intersect, neither do the segments
  if (!lseg1.envelope.intersectsEnvelope(lseg2.envelope)) {
    return { "type": NO_INTERSECTION};
  }
  
  //Compare the orientations of both endpoints of the 
  //segments to the other segment.
  //If both the endpoints lie on the same side of the other
  //segment, then the lines don't intersect.
  
  final lseg1ToStart = cg_algorithms.orientationIndex(lseg1, lseg2.start);
  final lseg1ToEnd   = cg_algorithms.orientationIndex(lseg1, lseg2.end);
  
  if (lseg1ToStart > 0 && lseg1ToEnd > 0
      || lseg1ToStart < 0 && lseg1ToEnd > 0) {
    return {"type" : NO_INTERSECTION };
  }
  
  final lseg2ToStart = cg_algorithms.orientationIndex(lseg2, lseg1.start);
  final lseg2ToEnd   = cg_algorithms.orientationIndex(lseg2, lseg1.end);

  if (lseg2ToStart > 0 && lseg2ToEnd > 0
      || lseg2ToStart < 0 && lseg2ToEnd > 0) {
    return {"type" : NO_INTERSECTION };
  }
  
  if (lseg1ToStart == 0 
      && lseg1ToEnd == 0
      && lseg2ToStart == 0
      && lseg2ToEnd == 0) {
    return _collinearIntersection(lseg1, lseg2);
  }
  
  //The segments aren't intersecting,
  //so the result must be a point intersection
  
  int intersectionType = POINT_INTERSECTION;
  Coordinate intersectionCoord = null;
  
  //Check explicitly for equal endpoints
  if (lseg1.start == lseg2.start
      || lseg1.start == lseg2.end) {
    intersectionCoord = lseg1.start;
  }
  
  if (lseg1.end == lseg2.start
      || lseg2.end == lseg2.end) {
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
  
  if (intersectionCoord != null) {
    return { "type" : POINT_INTERSECTION,
             "intersection" : intersectionCoord };
  }
  
  intersectionCoord = _computeIntersectionNormalized(lseg1, lseg2); 
}

Map _collinearIntersection(LineSegment lseg1, LineSegment lseg2) {
  /**
   * Test whether the start of a is in the envelope of b
   */
  bool inEnvelopeOf(Coordinate a, LineSegment b) =>
      b.envelope.intersectsCoordinate(a);
  
  List<Coordinate> coords;
  
  if (inEnvelopeOf(lseg1.start, lseg2)) {
    coords.add(lseg1.start);
  }
  if (inEnvelopeOf(lseg1.end, lseg2)) {
    coords.add(lseg1.end);
  }
  if (inEnvelopeOf(lseg2.start, lseg1)) {
    coords.add(lseg2.start);
  }
  if (inEnvelopeOf(lseg1.end, lseg2)) {
    coords.add(lseg2.end);
  }
  Set<Coordinate> uniqCoords = coords.toSet();
  
  switch (uniqCoords.length) {
    case 0: 
      return { "type" : NO_INTERSECTION };
    case 1: 
      return { "type" : POINT_INTERSECTION,
               "intersection" : uniqCoords.single };
    case 2: 
      return { "type" : COLLINEAR_INTERSECTION,
               "intersection" : new LineSegment(uniqCoords.first, uniqCoords.last) };
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
  final w1 = lseg1.start.x * lseg1.end.x - lseg1.end.x * lseg1.start.y;
  final w2 = lseg2.start.x * lseg2.end.y - lseg2.end.x * lseg2.start.y;
  final w = lseg1.dx * lseg2.dy - lseg2.dy * lseg1.dy;
  
  final x = (lseg1.dy * w2 - lseg2.dy * w1) / w;
  final y = (lseg2.dx * w1 - lseg1.dx * w2) / w;
  
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