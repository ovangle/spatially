part of geometry;

class Tessel extends Geometry implements Planar {
  final Point a;
  final Point b;
  final Point c;
  
  LineSegment get ab      => new LineSegment(a, b);
  LineSegment get bc      => new LineSegment(b, c);
  LineSegment get ca      => new LineSegment(c, a);
  
  Tessel(Point this.a, Point this.b, Point this.c) {
    assert(a != b && a != c && b != c);
    if (colinear(a,b,c)) {
      throw new InvalidGeometry("Cannot form tessel from collinear points ($a, $b, $c)");
    }
  }
  
  factory Tessel.fromEdges(LineSegment ab, LineSegment bc, LineSegment ca) {
    var a,b,c;
    var edges = [ab,bc,ca];
    for (var i in range(3)) {
      var prev = (i == 0) ? ca : edges[i - 1];
      if (edges[i].start.notEqualTo(prev.end)) {
        throw new InvalidGeometry("Segments $prev and ${edges[i]} not adjacent");
      }
    }
    return new Tessel(ab.start, bc.start, ca.start);
  }
  
  Bounds get bounds {
    final ps = [a, b, c];
    return new Bounds(bottom: ps.map((p) => p.y).fold(double.INFINITY, math.min),
                      top:    ps.map((p) => p.y).fold(double.NEGATIVE_INFINITY, math.max),
                      left:   ps.map((p) => p.x).fold(double.INFINITY, math.min),
                      right:  ps.map((p) => p.x).fold(double.NEGATIVE_INFINITY, math.max));
                      
  }
  
  Point get centroid => new Point(x: (a.x + b.x + c.x) / 3,
                                  y: (a.y + b.y + c.y) / 3);
  
  Linestring get boundary => new Linestring([a, b, c, a]);
  
  Tessel translate({double dx: 0.0, double dy: 0.0}) 
      => new Tessel(a.translate(dx: dx, dy: dy),
                    b.translate(dx: dx, dy: dy),
                    c.translate(dx: dx, dy: dy));
  
  Tessel rotate(double dt, {Point origin : null}) {
    if (origin == null) origin = centroid;
    return new Tessel(a.rotate(dt, origin: origin),
                      b.rotate(dt, origin: origin),
                      c.rotate(dt, origin: origin));
  }
  
  Tessel scale(double ratio, {Point origin: null}) {
    if (origin == null) origin = centroid;
    return new Tessel(a.scale(ratio, origin: origin),
                      b.scale(ratio, origin: origin),
                      c.scale(ratio, origin: origin));
  }
  
  Tessel permute([int i = 1]) {
    switch (i % 3) {
      case 0: 
        return this;
      case 1:
        return new Tessel(b, c, a);
      case 2:
        return new Tessel(c, a, b);
    }
  }
  
  double distanceTo(Geometry geom) {
    if (encloses(geom)) return 0.0;
    return boundary.segments.fold(0.0, (d, seg) => math.min(d, seg.distanceTo(geom)));
  }
 
  LineSegment get _base   => new LineSegment(a, b);
  double      get _height => _base.distanceTo(c);
  
  double get area => 0.5 * _base.span * _height;
  
  Geometry _segmentIntersection(LineSegment lseg, {double tolerance: 1e-15}) {
    final enclosesStart = _enclosesPoint(lseg.start, tolerance: tolerance);
    final enclosesEnd   = _enclosesPoint(lseg.end, tolerance: tolerance);
    
    if (enclosesStart && enclosesEnd) return lseg;
    final boundaryIntersections = 
        boundary.segments
                .map((s) => lseg.intersection(s))
                .where((s) => s != null)
                .toSet();
    if (boundaryIntersections.any((i) => i is LineSegment)) {
      return boundaryIntersections.singleWhere((i) => i is LineSegment);
    }
    switch(boundaryIntersections.length) {
      case 0: //No intersection
        return null;
      case 1: //One of the edges is a subsegment of lseg
        final intersection = boundaryIntersections.single;
        if (intersection.equalTo(lseg.start)) return lseg.start;
        if (intersection.equalTo(lseg.end))   return lseg.end;
        if (enclosesStart) 
          return new LineSegment(lseg.start, intersection);
        if (enclosesEnd)
          return new LineSegment(intersection, lseg.end);
        return intersection;
      case 2: //The segment intersects at two places
        final intersection1 = boundaryIntersections.first;
        final intersection2 = boundaryIntersections.last;
        if (intersection1.distanceTo(lseg.start) < intersection2.distanceTo(lseg.start) ) {
          return new LineSegment(intersection1, intersection2);
        }
        return new LineSegment(intersection2, intersection1);
     }
  }
  
  /**
   * Returns the area common two the to two [Tessels], allowing for 
   * a maximum innacuracy of the intersection of [:tolerance:]
   * 
   * Returns one of
   * -- A Point, if the two [Tessel]s intersect at one of the vertices of the [Tessels]
   * -- A [LineSegment], if the two [Tessels] intersect along one of the edges
   * -- A [Ring], if the two [Tessel]s overlap.
   */  
  Geometry _tesselIntersection(Tessel tesl, {double tolerance: 1e-15}) {
    if (!boundsIntersects(tesl, tolerance: tolerance)) {
      return null;
    }
    // If there are no intersecting segments, then since Tessels are their own
    // convex hulls, this will contain a point if the tessels intersect at a single point
    // or null otherwise.
    Point intersectionPoint;
    // The list of segments surrounding the intersection of the two tessels, ordered
    // so that adjacent segments are adjacent in the intersection.
    // Once both tessels are processed, this should contain all the segments required
    // for the boundary.
    List<LineSegment> intersectionSegments = [];
    void findBoundaryIntersections(Iterable<LineSegment> segs, 
                                   Geometry intersectSeg(LineSegment lseg)) {
      for (var seg in segs) {
        final intersection = intersectSeg(seg);
        if (intersection is Point) 
          intersectionPoint = intersection;
        if (intersection is LineSegment) {
          intersectionSegments = _insertBeforeAdjacent(intersection, intersectionSegments);
        }
      }
    }
    findBoundaryIntersections(boundary.segments, tesl._segmentIntersection);
    findBoundaryIntersections(tesl.boundary.segments, _segmentIntersection);
    
    if (intersectionSegments.isEmpty) {
      //Tessels do not intersect or intersect at a point
      return intersectionPoint;
    } else if (intersectionSegments.length == 1) {
      //Tessels intersect along an edge
      return intersectionSegments.single;
    }
    return new Ring.fromSegments(intersectionSegments);
  }
  
  Geometry intersection(Geometry geom) {
    if (!boundsIntersects(geom)) 
      return null;
    if (geom is Point) {
      return encloses(geom) ? geom : null;
    }
    if (geom is LineSegment) 
      return _segmentIntersection(geom);
    
    if (geom is Linestring) {
      var intersections = 
          new GeometryList.from(
              geom.segments
                  .map((s) => _segmentIntersection(s))
                  .where((isect) => isect != null)
          ).simplify();
      return (intersections.length == 1) ? intersections.single : intersections;
    }
    
    if (geom is Tessel) {
      return _tesselIntersection(geom);
    }
    
    return geom.intersection(this);
  }
  
  _tesselUnion(Tessel tesl, {double tolerance: 1e-15}) {
    if (!boundsIntersects(tesl, tolerance: tolerance)
        || disjoint(tesl, tolerance: tolerance)) {
      return new GeometryList.from([this, tesl], growable: false);
    }
    //Given a linesegment `lseg1` which is 
    //1. enclosed by lseg2; and
    //2. shares either a start or end point with lseg2
    //returns the portion of `lseg2` not covered by lseg1.
    //returns `null` if lseg1 encloses lseg2
    LineSegment complementOf(LineSegment lseg1, LineSegment lseg2) {
      if (lseg1.encloses(lseg2)) return null;
      final resultStart = 
          [lseg2.start, lseg2.end].contains(lseg1.start) ? lseg1.end : lseg1.start;
      final resultEnd = 
          [lseg1.start, lseg1.end].contains(lseg2.start) ? lseg2.end : lseg2.start; 
      return new LineSegment(resultStart, resultEnd);
    }
    //The segments surrounding the union. When we're finished processing both
    //boundaries, this should consist of a list of adjacent linesegments.
    List<LineSegment> unionSegments = [];
    
    //Intersect each of the boundarySegments of one tessel with the other,
    //recording the portion of the boundary which is outside the other.
    void findUnionSegments(Iterable<LineSegment> boundarySegments,
                           Geometry intersectOther(LineSegment lseg),
                           Geometry intersectOtherBoundary(LineSegment lseg)) {
      for (var seg in boundarySegments) {
        final intersection = intersectOther(seg);
        if (intersection is LineSegment) {
          var boundaryIntersection = intersectOtherBoundary(intersection);
          if (boundaryIntersection is LineSegment) {
            //The intersection lies along the boundary of the other tessel,
            //thus forming part of the boundary of the union
            unionSegments = _insertBeforeAdjacent(intersection, unionSegments);
          }
          var intersectionComplement = complementOf(intersection, seg);
          if (intersectionComplement == null) {
            //The entire edge is enclosed by the union, and thus not
            //part of the boundary of the union
            continue;
          }
          unionSegments = _insertBeforeAdjacent(intersectionComplement, unionSegments);
        }
        if (intersection == null) {
          //This segment must lie entirely outside the other tessel
          unionSegments = _insertBeforeAdjacent(seg, unionSegments);
        }
      }
    }
    findUnionSegments(boundary.segments, tesl._segmentIntersection, tesl.boundary.intersection);
    findUnionSegments(tesl.boundary.segments, _segmentIntersection, boundary.intersection);
    return new Ring(new Linestring.fromLines(unionSegments, reverse: true)).simplify();
  }
  
  /**
   * Returns the [:union:] of two [Planar] geometries.
   * The result will be one of:
   * -- A [Tessel], if the [Tessel] encloses [:geom:]
   * -- A [Ring], if the two tessels intersection is nonempty
   * -- A [GeometryList], if the two geometries are disjoint.
   * 
   * NOTE: When intersecting a [Tessel] with a [Polygon], all holes in the polygon
   *       are ignored.
   */
  Geometry union(Planar geom, {double tolerance: 1e-15}) {
    if (disjoint(geom, tolerance: tolerance)) {
      return new GeometryList.from([this, geom]);
    }
    if (geom is Tessel) {
      return _tesselUnion(geom, tolerance: tolerance);
    }
  }
  
  bool intersects(Geometry geom, {double tolerance: 1e-15}) {
    if (!boundsIntersects(geom, tolerance: tolerance)) {
      return false;
    }
    if (geom is Point) return encloses(geom);
    if (geom is LineSegment) {
      return encloses(geom.start, tolerance: tolerance)
          || encloses(geom.end, tolerance: tolerance);
    }
    if (geom is Linestring) {
      return geom.segments.any((seg) => intersects(seg, tolerance: tolerance));
    }
    if (geom is Tessel) {
      return encloses(geom.a, tolerance: tolerance)
          || encloses(geom.b, tolerance: tolerance)
          || encloses(geom.c, tolerance: tolerance);
    }
    return geom.intersects(this, tolerance: tolerance);
  }
  
  bool _enclosesPoint(Point p, {double tolerance: 1e-15}) {
    final cmp_ab = ab.compareToPoint(p, tolerance: tolerance);
    if (cmp_ab == 0) return ab.encloses(p, tolerance: tolerance);
    final cmp_bc = bc.compareToPoint(p, tolerance: tolerance);
    if (cmp_bc == 0) return bc.encloses(p, tolerance: tolerance);
    final cmp_ca = ca.compareToPoint(p, tolerance: tolerance);
    if (cmp_ca == 0) return ca.encloses(p, tolerance: tolerance);
    
    //If the point is on the same side of all the edges, 
    //it is inside the tessel.s
    return cmp_ab > 0 && cmp_bc > 0 && cmp_ca > 0
        || cmp_ab < 0 && cmp_bc < 0 && cmp_ca < 0;
  }
  
  bool encloses(Geometry geom, {double tolerance: 1e-15}) {
    if (!boundsIntersects(geom)) return false;
    
    if (geom is Nodal) 
      return _enclosesPoint(geom.toPoint(), tolerance: tolerance);
    
    if (geom is Linear) {
      return geom
          .toLinestring()
          .every((v) => encloses(v, tolerance: tolerance));
    }
    
    if (geom is Tessel) {
      return encloses(geom.boundary, tolerance: tolerance);
    }
    
    if (geom is GeometryCollection) {
      return geom.every((g) => encloses(g, tolerance: tolerance));
    }
    
    if (geom is Polygon) {
      return encloses(geom.outer, tolerance: tolerance);
    }
    
    throw new Exception("Unknown geometry type: ${geom.runtimeType}");
    
  }
  
  /**
   * A [Tessel] is it's own tesselation. Returns a singleton set containing `this`.
   */
  Set<Tessel> tesselate({double tolerance: 1e-15}) => [this].toSet();
  
  /**
   * [Tessel]s cannot be simplified, just returns `this`
   */
  Tessel simplify({double tolerance: 1e-15}) => this;
  
  Polygon toPolygon() => new Polygon(outer: new Ring([a,b,c]));
  
  //TODO: Add {bool permuted} argument to match against permuted tessels
  //      Do same for linesegment
  bool equalTo(Geometry geom, {double tolerance: 1e-15}) {
    if (geom is Tessel) {
      return geom.a.equalTo(a, tolerance: tolerance)
          && geom.b.equalTo(b, tolerance: tolerance)
          && geom.c.equalTo(c, tolerance: tolerance);
    }
    return false;
  }
  
  bool touches(Geometry geom, {double tolerance: 1e-15}) {
    if (geom is Nodal) {
      return boundary.segments.any((s) => s.encloses(geom, tolerance: tolerance));
    }
    if (geom is LineSegment) {
      //If the intersection lies along any edge then it touches the tessel.
      for (var seg in boundary.segments) {
        if (seg._segmentIntersection(geom, tolerance: tolerance) is LineSegment) {
          return true;
        }
      }
      //Otherwise, the segment must either start or end at the boundary
      //but cannot both start and end at the boundary (because then it would need
      //to lie inside the geometry.
      if (boundary.encloses(geom.start, tolerance: tolerance)) {
        return !boundary.encloses(geom.end, tolerance: tolerance);
      }
      if (boundary.encloses(geom.end, tolerance: tolerance)) {
        return !boundary.encloses(geom.start, tolerance: tolerance);
      }
      return false;
    }
    if (geom is Linestring) {
      bool foundTouch = false;
      for (var seg in geom.segments) {
        final boundaryIntersection = boundary.intersection(seg);
        
        if (boundaryIntersection is Point) {
          var isectPoint = boundaryIntersection as Point;
          
          //If the segment intersects at a point, there is a possibility
          //that the linestring touches the polygon at a vertex and then
          //immediately moves in the opposite direction
          if (isectPoint.equalTo(seg.start, tolerance: tolerance)
              || isectPoint.equalTo(seg.end, tolerance: tolerance)) {
            //we can test this by intersecting the tessel with the segment.
            //If it intersects at a single point we are ok.
            var isect = _segmentIntersection(seg, tolerance: tolerance);
            if (isect is! Point) {
              return false;
            }
          } else if(!isectPoint.equalTo(a, tolerance: tolerance)
                    && !isectPoint.equalTo(b, tolerance: tolerance)
                    && !isectPoint.equalTo(c, tolerance: tolerance)) {
            //Otherwise it is only valid if the point is the start or end point of an edge
            //of the tessel.
            return false;        
          }
          foundTouch = true;
        } else if (boundaryIntersection is LineSegment) {
          //The segment lies along an edges
          foundTouch = true;
        }
        //If the intersection is null then we haven't found a point which touches the boundary
      }
      return foundTouch;
    }
    if (geom is Tessel) {
      var isect = _tesselIntersection(geom, tolerance: tolerance);
      return (isect is Point || isect is LineSegment);
    }
    if (geom is GeometryList) {
      return geom.touches(this, tolerance: tolerance);
    }
  }
  bool operator ==(Object other) {
    if (other is Tessel) {
      //Two tessels compare equal if they can be permuted to match the other tessel.
      return other.a == a && other.b == b && other.c == c;
    }
    return false;
  }
  
  int get hashCode {
    int result = 17;
    result = result * 17 + a.hashCode;
    result = result * 17 + b.hashCode;
    result = result * 17 + c.hashCode;
    return result;
  }
  
  String toString() => "Tessel($a, $b, $c)";
}

/**
 * Given a list of segments, inserts [:lseg:] at the first position in
 * the list which would make it either:
 * 1. adjacent to the start of the first segment; or 
 * 2. adjacent to the end of the previous segment
 * reversing the segment if necessary.
 * 
 * If not adjacent to any of the segments in the list, appends it to the end.
 */
List<LineSegment> _insertBeforeAdjacent(LineSegment lseg, List<LineSegment> segmentList) {
  if (segmentList.isEmpty) {
    segmentList.add(lseg);
  }
  if (segmentList.contains(lseg) 
      || segmentList.contains(lseg.reversed)) {
    return segmentList;
  }
  if (lseg.end == segmentList.first.start) {
    segmentList.insert(0, lseg);
    return segmentList;
  } else if (lseg.start == segmentList.first.start) {
    segmentList.insert(0, lseg.reversed);
    return segmentList;
  }
  
  for (var i in range(1, segmentList.length)) {
    if (lseg.start == segmentList[i - 1].end) {
      segmentList.insert(i, lseg);
      return segmentList;
    } else if (lseg.end == segmentList[i - 1].end) {
      segmentList.insert(i, lseg.reversed);
      return segmentList;
    }
  }
  
  //If we haven't added it, append it to the end of the list
  segmentList.add(lseg);
  return segmentList;
}