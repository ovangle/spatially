part of geometry;


class Bounds {
  final double top;
  final double bottom;
  final double left;
  final double right;
  
  
  Point get topLeft     => new Point(x: left,   y: top);
  Point get topRight    => new Point(x: right,  y: top);
  Point get bottomLeft  => new Point(x: left,   y: bottom);
  Point get bottomRight => new Point(x: right,  y: bottom);
  
  /**
   * The [:width:] of the object. 
   */
  double get width => right - left;
  
  /**
   * The [:height:] of the object. 
   */
  double get height => top - bottom;
  
  double get area   => width * height;
  
  Point get center => new Point(x: (left + right) / 2, 
                                y: (bottom + top) / 2);
  
  
  /**
   * Returns a new [Bounds] object from it's extents.
   */
  Bounds({double this.top,
          double this.bottom,
          double this.left,
          double this.right}) {
    if (top < bottom) {
      throw new InvalidGeometry("Top of bounds object must be smaller than bottom");
    }
    if (right < left) {
      throw new InvalidGeometry("Right of bounds object must be smaller than left");
    }
  }
  /**
   * Creates a new [Bounds] object at the given point, extending [:width:]
   * along the positive x axis and [:height:] along the positive y axis
   */
  Bounds.atPoint({ Point bottomLeft,
                   double width,
                   double height })
      : this(bottom : bottomLeft.y,
             left   : bottomLeft.x,
             top    : bottomLeft.y + height,
             right  : bottomLeft.x + width);
  
  /**
   * Creates a new bounds object from the specified [:bottomLeft:] and
   * [:topRight:] corners
   */
  Bounds.fromDiagonal({Point bottomLeft, Point topRight})
      : this(bottom : bottomLeft.y,
             top    : topRight.y,
             left   : bottomLeft.x,
             right  : topRight.x);
  
  /**
   * Scale the [Bounds] object by the specified [:ratio:]]
   * If [:origin:] is null or not provided, the center of the [Bounds] will be used.
   */
  Bounds scale(double ratio, {Point origin: null}) {
    if (origin == null) origin = center;
    return new Bounds.fromDiagonal(
        bottomLeft: this.bottomLeft.scale(ratio, origin: origin),
        topRight:   this.topRight.scale(ratio, origin: origin));
  }
  
  /**
   * Translate the [Bounds] by [:dx:] in the positive x direction
   * and [:dy:] in the positive y direction.
   */
  Bounds translate({double dx: 0.0, double dy: 0.0}) {
    return new Bounds.fromDiagonal(
        bottomLeft: bottomLeft.translate(dx: dx, dy: dy),
        topRight:   topRight.translate(dx: dx, dy: dy));
  }
  
  /**
   * Returns the union of this [Bounds] object with another [Bounds]
   */
  Bounds union(Bounds b) {
    return new Bounds(
        bottom: math.min(bottom, b.bottom),
        top   : math.max(top, b.top),
        left  : math.min(left, b.left),
        right : math.max(right, b.right));
  }
  /**
   * Extends the [Bounds] to contain the given [LatLng], [Bounds] or [Geometry]
   */
  Bounds extend(dynamic o) {
    if (o is Bounds) return union(o);
    if (o is! Geometry) {
      throw new Exception("Not a geometry: $o");
    }
    return union(o.bounds);
  }
  /**
   * Wrap the [Bounds] so that the longitudinal extent is contained within [:worldBounds:]
   */
  Bounds wrapDateLine(Bounds worldBounds) {
    var newBounds = this;
    //Shift west until intersecting world bounds
    while(newBounds.right >= worldBounds.left) {
      newBounds = newBounds.translate(dx: -worldBounds.width);
    }
    //Shft east until intersecting world bounds
    while(newBounds.right < worldBounds.left) {
      newBounds = newBounds.translate(dx: worldBounds.width);
    }
    //If we're intersecting the east border of world bounds
    //Shift west one more time
    if (newBounds.right < worldBounds.left && newBounds.right > worldBounds.right) {
      newBounds = newBounds.translate(dx: -worldBounds.width);
    }
    return newBounds;
  }
  
  /**
   * Tests whether the [Bounds] contains the given [LatLng]
   */
  bool contains(Point p, {double tolerance: 1e-15}) {
    return utils.compareDoubles((bottom < top) ? bottom : top,  p.y, tolerance) <= 0
        && utils.compareDoubles((bottom < top) ? top : bottom,  p.y, tolerance) >= 0
        && utils.compareDoubles((left < right) ? left : right,  p.x, tolerance) <= 0
        && utils.compareDoubles((left < right) ? right : left,  p.x, tolerance) >= 0;
    }
  
  /**
   * Tests whether the given [Bounds] object is intersecting.
   */ 
  bool intersects(Bounds other, {double tolerance: 1e-15}) {
    return contains(other.bottomLeft,   tolerance: tolerance)
        || contains(other.bottomRight,  tolerance: tolerance)
        || contains(other.topLeft,      tolerance: tolerance)
        || contains(other.topRight,     tolerance: tolerance)
        || other.contains(center,       tolerance: tolerance);
  }
  
  /**
   * Tests whether [:other:] is entirely enclosed by the bounds
   */
  bool encloses(Bounds other, {double tolerance: 1e-15}) {
    return contains(other.bottomLeft,   tolerance: tolerance)
        && contains(other.bottomRight,  tolerance: tolerance)
        && contains(other.topLeft,      tolerance: tolerance)
        && contains(other.topRight,     tolerance: tolerance);
  }
  
  /**
   * Tests whether equal to [Bounds] object [:other:] within a given [:tolerance:]
   */
  bool equalTo(Bounds other, {double tolerance}) {
    return bottomLeft.equalTo(other.bottomLeft, tolerance: tolerance)
        && topRight.equalTo(other.topRight,     tolerance: tolerance);
  }
  
  bool operator ==(Object o) {
    if (o is Bounds) {
      return o.bottomLeft == bottomLeft
          && o.topRight   == topRight;
    }
    return false;
  }
  
  int get hashCode {
    var hash = 41;
    hash = hash * 41 + top.hashCode;
    hash = hash * 41 + bottom.hashCode;
    hash = hash * 41 + left.hashCode;
    hash = hash * 41 + right.hashCode;
    return hash + 41;
  }
  
  String toString() => 
      "Bounds(left: $left, bottom: $bottom, right: $right, top: $top)";
}