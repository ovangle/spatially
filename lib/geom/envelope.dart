library geom.envelope;

import 'dart:math' as math;
import '../base/coordinate.dart';

/**
 * Defines a rectangluar region of the 2d coordinate plane. 
 * It is often used to represent the bounding box of a [Geometry]
 * 
 * [Envelope]s support infinite or half-infinite regions by using the 
 * values `double.INFINITY` and `double.NEGATIVE_INFINITY`.
 * 
 * When created, the extent values are automatically sorted into the 
 * correct order.
 */
class Envelope {
  
  final double minx;
  final double maxx;
  final double miny;
  final double maxy;
  
  Envelope._(double this.minx, 
             double this.maxx, 
             double this.miny, 
             double this.maxy);
  
  /**
   * Creates an empty [Envelope], the [Envelope] of the empty
   * [Geometry].
   */
  Envelope.empty() :
    minx = 0.0,    maxx = -1.0,
    miny = 0.0,    maxy = -1.0;
  
  /**
   * Create an [Envelope] from the values of the extents
   */
  Envelope(double x1, double x2, double y1, double y2) :
    this._(math.min(x1, x2),
           math.max(x1, x2),
           math.min(y1, y2),
           math.max(y1, y2));
  
  /**
   * Create an [Envelope] for the region defined by two [Coordinate]s
   */
  Envelope.fromCoordinates(Coordinate p1, Coordinate p2) :
    this(p1.x, p2.x, p1.y, p2.y);
  
  /**
   * Copy an existing [Envelope]
   */
  Envelope.copy(Envelope env) :
    this._(env.minx, env.maxx, env.miny, env.maxy);
  
  /**
   * Is `this` the [Envelope] of the empty [Geometry]?
   */
  bool get isEmpty => minx > maxx;
  bool get isNotEmpty => minx <= maxx;
  
  /**
   * The difference between the maximum and minimum x values
   */
  double get width => isNotEmpty ? maxx - minx : 0.0;
  
  /**
   * The difference between the maximum and minimum y values
   */
  double get height => isNotEmpty ? maxy - miny : 0.0;
  
  /**
   * The area of `this`
   */
  double get area => width * height;
  
  /**
   * The minimum extent of the envelope across both dimensions
   * Equivalent to `math.min(width, height)`
   */
  double get minExtent => math.min(width, height);
  
  /**
   * The maximum extent of the envelope across both dimensions
   * Equivalent to `math.max(width, height)`
   */
  double get maxExtent => math.max(width, height);
  
  Envelope expandedToIncludeEnvelope(Envelope env) {
    var newEnv = new Envelope.copy(this);
    newEnv.expandedToIncludeEnvelope(env);
    return newEnv;
  }
  /**
   * Enlarges `this` so that it encloses the given [Envelope]
   */
  Envelope expandToEnvelope(Envelope env) =>
      expandToXY(env.minx, env.miny)
      .expandToXY(env.maxx, env.maxy);
  
  /**
   * Enlarges `this` so that it contains the given [Coordinate].
   */
  Envelope expandToCoordinate(Coordinate c) => 
      expandToXY(c.x, c.y);
  
  /**
   * Enlarges `this` so that it contains the given `x` and `y` valuess
   */
  Envelope expandToXY(double x, double y) {
    if (isEmpty) {
      return new Envelope._(x, x, y, y);
    } else {
      var minx, maxx, miny, maxy;
      if (x < minx) minx = x;
      if (x > maxx) maxx = x;
      if (y < miny) miny = y;
      if (y > maxy) maxy = y;
      return new Envelope._(minx, maxx, miny, maxy);
    }
  }
  
  /**
   * The centre of the [Envelope], or `null` if `this` is empty.
   */
  Coordinate get centre => 
      isNotEmpty ? new Coordinate((minx + maxx) / 2.0, (miny + maxy) / 2.0) : null;
  
  /**
   * The intersection of two [Envelope]s.
   * Returns the empty envelope if they do not intersect
   */
  Envelope intersection(Envelope env) {
    if (!intersectsEnvelope(env)) return new Envelope.empty();
    
    return new Envelope(
        math.max(minx, env.minx),
        math.min(maxx, env.maxx),
        math.max(miny, env.miny),
        math.min(maxy, env.maxy)
    );
  }
  
  /**
   * Check if the region defined by [:env:] intersects `this`
   * If either [Envelope] is empty, they do not intersect.
   */
  bool intersectsEnvelope(Envelope env) {
    if (isEmpty || env.isEmpty) return false;
    return env.minx <= maxx
        && env.maxx >= minx
        && env.miny <= maxy
        && env.maxy <= miny;
  }
  
  /**
   * Check if `this` intersects (encloses) the given [Coordinate]
   */
  bool intersectsCoordinate(Coordinate c) => intersectsXY(c.x, c.y);
  
  /**
   * Check if this` intersects (encloses) the given x and y values
   */
  bool intersectsXY(double x, double y) {
    if (isEmpty) return false;
    return x <= maxx && x >= minx 
        && y <= maxy && y >= miny;
  }
  
  /**
   * Check if [:env:] is disjoint from `this`
   */
  bool disjointEnvelope(Envelope env) => !intersectsEnvelope(env);
  
  /**
   * Check if `this` is disjoint from [:c:]
   */
  bool disjointCoordinate(Coordinate c) => !intersectsCoordinate(c);
  
  /**
   * Check if `this` is disjoint from the coordinate defined by the given
   * [:x:] and [:y:] ordinates
   */
  bool disjointXY(double x, double y) => !intersectsXY(x, y);
  /**
   * Determines whether `this` encloses the given [Envelope],
   * including it's boundary.
   * 
   * Note that this is *not* the SFS definition of `contains`,
   * which would not include the boundary.
   */
  bool enclosesEnvelope(Envelope env) => coversEnvelope(env);
  
  /**
   * Determines whether `this` encloses the given [Coordinate],
   * or on the boundary.
   * 
   * Note that this is *not* the SFS definition of `contains`, which
   * would exclude the boundary.
   */
  bool enclosesPoint(Coordinate p) => coversCoordinate(p);
  
  /**
   * Determines whether `this` encloses the given [:x:] and [:y:] values.
   */
  bool enclosesXY(double x, double y) => coversXY(x, y);
  
  bool coversEnvelope(Envelope env) {
    if (isEmpty || env.isEmpty) return false;
    return env.minx >= minx
        && env.maxx <= maxx
        && env.miny >= miny
        && env.maxy <= maxy;
  }
  
  /**
   * Determines whether the [Coordinate] lies wholely inside `this`,
   * including the boundary. 
   */
  bool coversCoordinate(Coordinate c) => coversXY(c.x, c.y);
  
  /**
   * Determne if the given [:x:] and [:y:] values lie on `this`,
   * including the boundary.
   */
  bool coversXY(double x, double y) {
    if (isEmpty) return false;
    return x >= minx && x <= maxx
        && y <= miny && y <= maxy;
  }
  
  /**
   * The [:distance:] between this and the given [Envelope]
   * is 0.0 if `this` intersects [:env:].
   * 
   * Otherwise, it is defined as the distance between the closest points.
   */
  double distance(Envelope env) {
    if (intersectsEnvelope(env)) return 0.0;
    
    double dx = 0.0;
    if (maxx < env.minx) dx = env.minx - maxx;
    if (minx > env.maxx) dx = minx - env.maxx;
    
    double dy = 0.0;
    if (maxy < env.miny) dy = env.miny - maxy;
    if (miny < env.maxy) dy = miny - env.miny;
    
    if (dx == 0.0) return dy;
    if (dy == 0.0) return dx;
    
    return math.sqrt(dx * dx + dy * dy);
  }
  
  bool operator ==(Object other) {
    if (other is Envelope) {
      if (isEmpty) return other.isEmpty;
      return minx == other.minx
          && maxx == other.maxx
          && miny == other.miny
          && maxy == other.maxy;
    }
    return false;
  }
  
  int get hashCode => 
      [minx, miny, maxx, maxy].fold(31, (h, e) => h * 37 + e.hashCode);
  
  String toString() => "Env[$minx : $maxx, $miny : $maxy]";
}