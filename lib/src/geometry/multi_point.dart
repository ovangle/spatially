part of geometry;

class MultiPoint extends GeometryCollection<Point> implements MultiGeometry<Point> {
  
  MultiPoint(Iterable<Nodal> nodes) : super(nodes, false);
  
  Point get centroid {
    if (isEmpty) {
      throw new InvalidGeometry("Empty MultiPoint has no centroid");
    }
    final sumX = fold(0.0, (s, p) => s + p.x);
    final sumY = fold(0.0, (s, p) => s + p.y);
    
    return new Point(x: sumX / length, y: sumX / length);
  }
  
  MultiPoint translate({double dx: 0.0, double dy: 0.0}) {
    return new MultiPoint(map((p) => p.translate(dx: dx, dy: dy)));
  }
  
  MultiPoint rotate(double dt, {Point origin}) {
    //rotating an empty MultiPoint does nothing
    if (isEmpty) return this;
    if (origin == null) origin = centroid;
    return new MultiPoint(map((p) => p.rotate(dt, origin: origin)));
  }
  
  MultiPoint scale(double ratio, {Point origin}) {
    //scaling an empty MultiPoint does nothing
    if (isEmpty) return this;
    if (origin == null) origin = centroid;
    return new MultiPoint(map((p) => p.scale(ratio, origin: origin)));
  }
  
  Geometry intersection(Geometry geom) {
    if (geom is Nodal) {
      return new MultiPoint(where(geom.toPoint().equalTo));
    } else {
      return new MultiPoint(where(geom.encloses));
    }
  }
  
  bool intersects(Geometry geom) => any(geom.intersects);
  bool encloses(Geometry geom) => any(geom.encloses);
  bool touches(Geometry geom) {
    bool foundTouch;
    for (var p in this) {
      if (geom.touches(p)) {
        foundTouch = true;
      }
      
    }
  }
  
  
}