part of geometry;

/**
 * Tests whether the list of points all lie along the same line up to a given tolerance
 */
bool colinear(Point p_a, Point p_b, Point p_c, {double tolerance: 1e-15}) {
  var ab = new LineSegment(p_a, p_b);
  var bc = new LineSegment(p_b, p_c);
  var discr = ab._aCoeff * bc._bCoeff - bc._aCoeff * ab._bCoeff;
  return utils.compareDoubles(discr, 0.0, tolerance) == 0;
}

class Point extends Geometry implements Nodal {
  
  static const _O = const Point(x: 0.0, y: 0.0);
  
  final double x;
  final double y;
  
  Point get centroid => this;
  Bounds get bounds  => new Bounds(top: y, bottom: y, left: x, right: x);
  
  GeometryList get mutableCopy {
    throw new UnsupportedError("Cannot create a mutable copy of Point type");
  }
  
  const Point({double this.x, double this.y});
  
  Point translate({double dx: 0.0, double dy: 0.0}) {
    return new Point(x: x + dx, 
                     y: y + dy);
  }
  
  Point rotate(double dt, {Point origin: null}) {
    if (origin == null) origin = centroid;
    final dx = x - origin.x; final dy = y - origin.y;
    
    final r = math.sqrt(dx * dx + dy * dy);
    final t = math.atan2(dy, dx);

    return new Point(x: origin.x + r * math.cos(t + dt),
                     y: origin.y + r * math.sin(t + dt));
  }
  
  Point scale(double ratio, {origin: null}) {
    if (origin == null) origin = centroid;
    return new Point(x: (x - origin.x) * ratio + origin.x,
                     y: (y - origin.y) * ratio + origin.y);
  }
  
  double distanceTo(Point p) => math.sqrt(distanceToSqr(p));
  
  /**
   * The square of the distance to [:other:].
   */
  double distanceToSqr(Point p) {
      final dx = x - p.x;
      final dy = y - p.y;
      return dx * dx + dy * dy;
  }
  
  /**
   * The geometry enclosing precisely those points which are
   * enclosed by `this` and enclosed by `geom`.
   * 
   * If [:geom:] is a [Point], then will return either a
   *   -- [Point], if the two points are equal
   *   -- `null`, if the two points are not equal
   *   
   * Otherwise, the return type is dependent on the type of the [Geometry].
   * Check the documentation of the type for further information
   */
  Geometry intersection(Geometry geom) {
    switch(geom.runtimeType) {
      case Point:
        return this == geom ? this : null;
      default:
        return geom.intersection(this);
    }
  }
  
  /**
   * The geometry enclosing precisely those points which are
   * enclosed by `this` or enclosed by `geom`.
   * 
   * If [:geom:] is a [Point], then will return either a
   *   -- [MultiPoint], if the two points are not equal
   *   -- [Point], if the two points are equal
   *   
   * Otherwise, the return type is dependent on the type of the [Geometry].
   * Check the documentation of the type for further information
   */
  Geometry union(Geometry geom) {
    switch(geom.runtimeType) {
      case Point:
        return this == geom ? this : new MultiPoint([this, geom]);
      default:
        return geom.union(this);
    }
  }
  
  /**
   * The geometry enclosing precisely those points which are
   * enclosed by `this` or enclosed by `geom`.
   * 
   * For all geometry types, the result is either a:
   *  -- [Point], if the geometry is [disjoint] from `this`
   *  -- `null` if the geometry intersects `this` 
   */
  Geometry difference(Geometry geom) {
    return geom.disjoint(this) ? this : null;
  }
  
  /**
   * [Point]s can't be simplified, just returns the point
   */
  //TODO: simplify should affect the number of sigfigs in the precision somehow.
  Point simplify({double tolerance: 1e-15}) => this;
  
  bool encloses(Geometry geom) {
    if (geom is Point) {
      return geom == this;
    }
    if (geom is MultiPoint) {
      return geom.isNotEmpty && geom.every(encloses);
    }
    if (geom is LineSegment) {
      return encloses(geom.start) && encloses(geom.end); 
    }
    throw "Point.encloses not implemented for ${geom.runtimeType}";
  }
  
  bool intersects(Geometry geom) {
    if (geom is Point) {
      return geom.toPoint() == this;
    }
    return geom.intersects(this);
  }
  
  bool touches(Geometry geom) {
    if (geom is Nodal) {
      return geom.toPoint() == this;
    }
    return geom.touches(this);
  }
  
  Point toPoint() => this;
  
  bool operator ==(Object other) {
    if (other is! Point) return false;
    var p = (other as Point);
    return p.x == x && p.y == y;
  }
  
  int get hashCode {
    int result = 37;
    result = result * 37 + x.hashCode;
    result = result * 37 + y.hashCode;
    return result;
  }
  
  String toString() => "Point(x: $x, y: $y)";
}