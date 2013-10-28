part of geometry;


class LineSegment extends Geometry implements Linear {
  final Point start;
  final Point end;
  
  GeometryList get mutableCopy {
    throw new UnsupportedError("Cannot construct mutable copy of LineSegment");
  }
  
  /**
   * The endpoint with the minimal x coorinate.
   */
  Point get left => start.x <= end.x ? start : end;
  /**
   * The point with the minimal x coordinate
   */
  Point get right => start.x <= end.x ? end : start;
  
  LineSegment(Point this.start, Point this.end);
  
  LineSegment reversed() => new LineSegment(end, start);
  
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
  
  double distanceTo(Geometry other) {
    if (other is Point) {
      var p = (other as Point);
      final a = _aCoeff; final b = _bCoeff; final c = _cCoeff;
      return (a * p.x + b * p.y + c).abs() 
           / math.sqrt(a * a + b * b);
    }
    if (other is LineSegment) {
      final lseg = other as LineSegment;
      if (intersects(other)) return 0.0;
      return [ distanceTo(lseg.start),
               distanceTo(lseg.end),
               lseg.distanceTo(start),
               lseg.distanceTo(end)]
             .fold(double.INFINITY, math.min);
    }
    if (other is Linestring) {
      var lstr = (other as Linestring);
      return lstr.segments
                 .fold(double.INFINITY, (dist, seg) => math.min(dist, this.distanceTo(seg)));
    }
    return other.distanceTo(this);
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
 
  bool equalTo(Geometry other, {double tolerance: 1e-15}) {
    if (other is LineSegment) {
      var lseg = other as LineSegment;
      return lseg.start.equalTo(start, tolerance: tolerance)
          && lseg.end.equalTo(end, tolerance: tolerance);
    }
    return false;
  }
  
  /**
   * Returns the [:intersection:] of this with another [LineSegment]
   * If the lines are disjoint, the output will be `null`.
   * If the lines intersect at a single point, the [Point] of intersection will be returned
   * If the lines are coincident for any non-zero portion of their lengths, 
   *  the [LineSegment] between the start and end point of the intersection will be returned,
   *  starting at the [:leftmost:] point of the coincidence, and ending at the [:rightmost:]
   *  point.
   */
  Geometry _segmentIntersection(LineSegment lseg, {double tolerance: 1e-15}) {
    final a1 = _aCoeff;      final b1 = _bCoeff;      final c1 = _cCoeff;
    final a2 = lseg._aCoeff; final b2 = lseg._bCoeff; final c2 = lseg._cCoeff;
    final discr = a1 * b2 - a2 * b1;
    
    bool intersectionEncloses(Point pt) =>
        encloses(pt, tolerance: tolerance)
        && lseg.encloses(pt, tolerance: tolerance);
    
    if (utils.compareDoubles(discr, 0.0, tolerance) == 0) {
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
  Geometry intersection(Geometry geom, {double tolerance: 1e-15}) {
    if (geom is Point) {
      if (encloses(geom, tolerance: tolerance)) return geom; 
    }
    if (geom is LineSegment) {
      return _segmentIntersection(geom, tolerance: tolerance);
    }
    if (geom is Linestring) {
      GeometryList intersections = new GeometryList();
      for (var seg in (geom as Linestring).segments) {
        var isect = intersection(seg, tolerance: tolerance);
        if (isect != null) {
          intersections.add(isect);
        }
      }
      return intersections;
    }
    return geom.intersection(this, tolerance: tolerance);
  }
  
  bool encloses(Geometry geom, {double tolerance: 1e-15}) {
    if (geom is Point) {
      if (compareToPoint(geom, tolerance: tolerance) != 0) return false;
      return bounds.contains(geom, tolerance: tolerance);
    }
    if (geom is LineSegment) {
      var lseg = geom as LineSegment;
      return encloses(lseg.start) && encloses(lseg.end);
    }
    if (geom is Linestring) {
      for (var p in (geom as Linestring)) {
        return encloses(p);
      }
    }
    return false;
  }
  
  /**
   * Returns `true` if the geometry touches one of the endpoints of the [Geometry].
   * -- If [:geom:] is a [Nodal] geometry, true iff the geom is the start or end point.
   * -- If [:geom:] is a [Linear] geometry, true iff the geom's start or end point touches the current geometry
   * -- If [:geom:] is a [Planar] geometry, true iff [:start:] or [:end:] is a point on the [:boundary:].
   * -- If [:geom:] is a [GeometryList], truee iff the geometry touches any of the elements of [:geom:]
   * 
   * **NOTE**: Unlike other geometric relations, [:touches:] is not commutative.
   */
  bool touches(Geometry geom, {double tolerance: 1e-15}) {
    if (geom is Nodal) {
      return geom.equalTo(start, tolerance: tolerance)
          || geom.equalTo(end, tolerance: tolerance);
    }
    if (geom is Linear) {
      return touches((geom as Linear).start, tolerance: tolerance)
          || touches((geom as Linear).end, tolerance: tolerance);
    }
    if (geom is Planar || geom is GeometryList) {
      return geom.touches(this, tolerance: tolerance);
    }
    throw new InvalidGeometry("unknown geometry type: ${geom.runtimeType}");
  }
 
  /**
   * [LineSegment]s can't be simplified, just returns this.
   */
  LineSegment simplify({double tolerance: 1e-15}) => this;
  
  Linestring toLinestring() => new Linestring([start, end]);
  
  Linestring append(Nodal node) => toLinestring().append(node);
  
  Linestring concat(Linear line, {double tolerance: 1e-15, bool reverse: false}) 
      => toLinestring().concat(line, tolerance: tolerance, reverse: reverse);
  
  
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