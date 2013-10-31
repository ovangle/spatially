part of geometry;


class LineSegment extends Geometry implements Linear {
  final Point start;
  final Point end;
  
  GeometryList get mutableCopy {
    throw new UnsupportedError("Cannot construct mutable copy of LineSegment");
  }
  
  MultiPoint get _boundary => new MultiPoint([start, end]);
  
  /**
   * The endpoint with the minimal x coorinate.
   */
  Point get left => start.x <= end.x ? start : end;
  /**
   * The point with the minimal x coordinate
   */
  Point get right => start.x <= end.x ? end : start;
  
  LineSegment(Point this.start, Point this.end);
  
  LineSegment get reversed => new LineSegment(end, start);
  
  Bounds get bounds =>
      new Bounds(
          bottom: math.min(start.y, end.y),
          top:    math.max(start.y, end.y),
          left:   math.min(start.x, end.x),
          right:  math.max(start.x, end.x));
  
  Point get centroid => new Point(x: (start.x + end.x) / 2,
                                  y: (start.y + end.y) / 2);
  
  //Coefficients of line a x + b y + c = 0
  double get _aCoeff => end.y - start.y;
  double get _bCoeff => start.x - end.x;
  double get _cCoeff => end.x * start.y - end.y * start.x;
  
  double get span => start.distanceTo(end);
  
  
  /**
   * Determines whether a given point is above or below the [LineSegment]
   * (when extended to infinity).
   * 
   * When facing in the direction of the line, returns
   *    1 if the point is more than a distance [:tolerance:] to the left of the line
   *    0 if the point is a distance less than [:tolerance:] from the line
   *    -1 if the point is more than a distance [:tolerance:] to the right of the line
   *    
   */
  int compareToPoint(Point p, {double tolerance: 1e-15}) {
    final a = _aCoeff; final b = _bCoeff; final c = _cCoeff;
    final cmp = utils.compareDoubles(a * p.x + b * p.y, -c, tolerance);
    return -cmp;
  }
  
  double distanceTo(Geometry geom) {
    if (geom is Point) {
      final a = _aCoeff; final b = _bCoeff; final c = _cCoeff;
      return (a * geom.x + b * geom.y + c).abs() 
           / math.sqrt(a * a + b * b);
    }
    if (geom is LineSegment) {
      if (intersects(geom)) return 0.0;
      return [ distanceTo(geom.start),
               distanceTo(geom.end),
               geom.distanceTo(start),
               geom.distanceTo(end)]
             .fold(double.INFINITY, math.min);
    }
    if (geom is Linestring) {
      return geom.segments
                 .fold(double.INFINITY, (dist, seg) => math.min(dist, this.distanceTo(seg)));
    }
    return geom.distanceTo(this);
  }
  
  LineSegment translate({double dx: 0.0, 
                         double dy: 0.0}) {
    return new LineSegment(
        start.translate(dx: dx, dy: dy),
        end.translate(dx: dx, dy: dy));
  }
  
  LineSegment rotate(double dt, {Point origin}) {
    if (origin == null) origin = centroid;
    return new LineSegment(
        start.rotate(dt, origin: origin),
        end.rotate(dt, origin: origin));
  }
  
  LineSegment scale(double ratio, {Point origin}) {
    if (origin == null) origin = centroid;
    return new LineSegment(
        start.scale(ratio, origin: origin),
        end.scale(ratio, origin: origin));
  }
 
  /**
   * Returns the [:intersection:] of this with another [LineSegment]
   * If the lines are disjoint, the output will be `null`.
   * If the lines intersect at a single point, the [Point] of intersection will be returned
   * If the lines are coincident for any non-zero portion of their lengths, 
   *  the [LineSegment] between the start and end point of the intersection will be returned,
   *  and the start of the returned segment will be the segment closest to [:start:]
   */
  //TODO: Should return a line in same direction as `this`
  Geometry _segmentIntersection(LineSegment lseg) {
    final a1 = _aCoeff;      final b1 = _bCoeff;      final c1 = _cCoeff;
    final a2 = lseg._aCoeff; final b2 = lseg._bCoeff; final c2 = lseg._cCoeff;
    final discr = a1 * b2 - a2 * b1;
    
    bool intersectionEncloses(Point pt) => encloses(pt) && lseg.encloses(pt);
    
    if (utils.compareDoubles(discr, 0.0, 1e-15) == 0) {
      // the lines are approximately parallel.
      var isectLeft, isectRight;
     
      if (intersectionEncloses(left))       isectLeft = left;
      if (intersectionEncloses(right))      isectRight = right;
      
      if (intersectionEncloses(lseg.left))  isectLeft = lseg.left;
      if (intersectionEncloses(lseg.right)) isectRight = lseg.right;
      if (isectLeft == isectRight) {
        return isectLeft;
      }
      if (isectLeft.x == isectRight.x) {
        //Ensure that the returned intersection is from the bottom to the top
        //of the coincidence.
        if (isectLeft.y > isectRight.y) return new LineSegment(isectRight, isectLeft);
      }
      return new LineSegment(isectLeft, isectRight);
    } else {
      final intersectionPoint = 
          new Point(
              y: (a2 * c1 - a1 * c2) / discr,
              x: (b1 * c2 - b2 * c1) / discr);
      if (intersectionEncloses(intersectionPoint)) {
        return intersectionPoint;
      }
    }
    return null;
  }
  
  /**
   * Return the geometry obtained by intersecting the segment 
   * with the given [Geometry].
   * 
   * The result of intersecting with a point or another [LineSegment] will
   * always be either a [Point] or a [LineSegment] (in the case that the two segments
   * were coincident for a portion of their lengths).
   * 
   * If the result is a [LineSegment], then the segment returned will be the one
   * travelling from the bottom left to the top right of the intersection.
   * 
   * Intersecting with other [Geometry] types can return a [GeometryList]
   * of [Point]s and [LineSegment]s.
   */
  Geometry intersection(Geometry geom) {
    if (geom is Point) {
      return (encloses(geom)) ? geom : null; 
    }
    if (geom is LineSegment) {
      return _segmentIntersection(geom);
    }
    return geom.intersection(this);
  }
  
  Geometry union(Geometry geom) {
    if (geom is Point) {
      if (encloses(geom))
        return this;
      return new GeometryList.from([geom, this], growable: false);
    }
    if (geom is LineSegment) {
      var isect = _segmentIntersection(geom);
    }
  }
  
  bool encloses(Geometry geom) {
    if (geom is Nodal) {
      if (compareToPoint(geom.toPoint()) != 0) return false;
      return bounds.enclosesPoint(geom.toPoint());
    }
    if (geom is Linear) {
      return geom.toLinestring().every(encloses);
    }
    return false;
  }
  
  bool intersects(Geometry geom) {
    if (geom is Point) {
      return encloses(geom);
    }
    if (geom is LineSegment) {
      return _segmentIntersection(geom) != null;
    }
    return geom.intersects(this);
  }
  
  /**
   * Returns `true` if the geometry touches one of the endpoints of the [Geometry].
   * -- If [:geom:] is a [Nodal] geometry, true iff the geom is the start or end point.
   * -- If [:geom:] is a [Linear] geometry, true iff the geom's start or end point touches the current geometry
   * -- If [:geom:] is a [Planar] geometry, true iff [:start:] or [:end:] is a point on the [:boundary:].
   * -- If [:geom:] is a [GeometryList], truee iff the geometry touches any of the elements of [:geom:]
   */
  bool touches(Geometry geom) {
    if (geom is Nodal) {
      return geom == start || geom == end;
    }
    if (geom is Linear) {
      final isect = intersection(geom);
      if (isect is MultiPoint) {
        return touches(isect);
      }
      return isect == start || isect == end;
    }
    return geom.touches(this);
  }
 
  /**
   * [LineSegment]s can't be simplified, just returns this.
   */
  LineSegment simplify({double tolerance: 1e-15}) => this;
  
  Linestring toLinestring() => new Linestring([start, end]);
  
  Linestring append(Nodal node) => toLinestring().append(node);
  
  Linestring concat(Linear line, {double tolerance: 0.0, bool reverse: false}) 
      => toLinestring().concat(line, tolerance: tolerance, reverse: reverse);
  
  /**
   * The geometry containing precisely the points which are 
   * enclosed by `this` and disjoint from [:geom:].
   * 
   * If [:geom:] is a [Point], then always returns `this`.
   * 
   * If [:geom:] is a [LineSegment], then always returns a 
   * -- A [MultiLinestring], if the intersection of `this` and [:geom:] is non-empty
   *    and doesn't contain either endpoint.
   * -- [LineSegment], if the intersection of `this` and [:geom:] 
   *    encloses either of the endpoints
   * -- `null`, if [:geom:] encloses `this`.
   */
  LineSegment difference(Geometry geom) {
    switch (geom.runtimeType) {
      case Point:
        return this;
      case LineSegment:
        var isect = _segmentIntersection(geom);
        if (isect is Point) {
          return this;
        }
        if (isect == null) {
          return this;
        }
        final containsStart = isect.encloses(start);
        final containsEnd   = isect.encloses(end);
        if (containsStart && containsEnd) {
          return null;
        } else if (containsStart) {
          final diffStart = 
              isect.start.distanceToSqr(start) <= isect.end.distanceToSqr(start)
              ? isect.start : isect.end;
          return new LineSegment(diffStart, end);
        } else if (containsEnd) {
          final diffEnd =
              isect.end.distanceToSqr(end) <= isect.start.distanceToSqr(end)
              ? isect.end : isect.start;
          return new LineSegment(start, diffEnd);
        }
        final resultStart = 
            [start, end].contains(isect.start) ? isect.end : isect.start;
        final resultEnd = 
            [isect.start, isect.end].contains(start) ? end : start; 
        return new LineSegment(resultStart, resultEnd);
      default:
        throw 'NotImplemented';
    }
  }
  
  bool operator ==(Object other) {
    if (other is! LineSegment) return false;
    return (other as LineSegment).start == start
        && (other as LineSegment).end   == end;
  }
  
  int get hashCode {
    var result = 41;
    result = result * 41 + start.hashCode;
    result = result * 41 + end.hashCode;
    return result;
  }
  
  String toString() => "LineSegment($start, $end)";
}