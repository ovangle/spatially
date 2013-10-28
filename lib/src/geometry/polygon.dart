part of geometry;

class Polygon extends Geometry implements Planar {
  final Ring outer;
  final List<Ring> holes;
  
  /**
   * Constructs a polygon given the outer ring of the polygon and the list
   * of holes.
   * 
   * If dart checked mode is active, the polygon is validated and an [InvalidGeometry] is
   * raised if:
   * 1. Any of the holes intersect the outside of the polygon
   * 2. Any of the holes intersect each other.
   */
  Polygon({Ring this.outer, Iterable<Ring> holes : const []}) 
      : this.holes = new List<Ring>.from(holes) {
// #ifdef DEBUG
    assert(() {
        for (var i in range(this.holes.length - 1)) {
          var hole = this.holes[i];
          if (!outer.encloses(hole)) {
            throw new InvalidGeometry("Outer ring of polygon intersects a hole in the polygon");
          }
          for (var j in range(i, this.holes.length - 1)) {
            if (!hole.disjoint(this.holes[j])) {
              throw new InvalidGeometry("Holes of polygon must be disjoint");
            }
          }
        }
        return true;
    }());
// #endif
  }
  /**
   * The boundary of the outer ring of the [Polygon]
   */
  Linestring get boundary => outerRing.boundary;
  double get area => outerRing.area - holes.fold(0.0, (curr, hole) => curr + hole.area);
  Point get centroid {
    
  }
  
  Polygon toPolygon() => this;
  
  
  bool operator ==(Object o) {
    if (o is! Polygon) return false;
    var poly = o as Polygon;
    if (poly.rings.length != rings.length) return false;
    for(var i in range(rings.length)) {
      if (rings[i] != poly.rings[i]) return false;
    }
    return true;
  }
  
  int get hashCode => rings.hashCode;
  
  String toString() => "Polygon($rings)";
}
