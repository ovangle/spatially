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
    final new_x = origin.x + r * math.cos(t + dt);
    final new_y = origin.y + r * math.sin(t + dt);
    return new Point(x: origin.x + r * math.cos(t + dt),
                     y: origin.y + r * math.sin(t + dt));
  }
  
  Point scale(double ratio, {origin: null}) {
    if (origin == null) origin = centroid;
    return new Point(x: (x - origin.x) * ratio + origin.x,
                     y: (y - origin.y) * ratio + origin.y);
  }
  
  double distanceTo(Point other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }
  
  /**
   * The square of the distance to [:other:].
   */
  double distanceToSqr(Point other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return dx * dx + dy * dy;
  }
  
  Geometry intersection(Geometry geom, {double tolerance: 1e-15}) {
    if (geom is Point) {
      if (equalTo(geom, tolerance: tolerance)) return this;
    }
    return geom.intersection(this, tolerance: tolerance);
  }
  
  /**
   * [Point]s can't be simplified, just returns the point
   */
  Point simplify({double tolerance: 1e-15}) => this;

  bool equalTo(Geometry geom, {double tolerance: 1e-15}) {
    if (geom is Point) {
      final p = geom as Point;
      return utils.compareDoubles(x, p.x, tolerance) == 0
          && utils.compareDoubles(y, p.y, tolerance) == 0;
    }
    return false;
  }
  
  bool encloses(Geometry geom, {double tolerance: 1e-15}) {
    if (geom is Point) {
      return equalTo(geom, tolerance: tolerance);
    }
    return false;
  }
  
  bool touches(Geometry geom, {double tolerance: 1e-15}) {
    if (geom is Point) {
      return equalTo(geom, tolerance: tolerance);
    }
    return geom.touches(this, tolerance: tolerance);
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