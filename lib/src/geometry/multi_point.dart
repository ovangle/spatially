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
    final intersections = where(geom.encloses);
    if (intersections.isEmpty) return null;
    if (intersections.length == 1) return intersections.single;
    return new MultiPoint(intersections);
  }
  
  Geometry difference(Geometry geom) {
    if (enclosedBy(geom)) {
      return null;
    }
    return new MultiPoint(where(geom.disjoint));
  }
  
  Geometry union(Geometry geom) {
    if (geom is Nodal) {
      if (encloses(geom)) return this;
      return add(geom);
    }
    if (geom is MultiPoint) {
      var newPoints = geom.where(disjoint);
      if (newPoints.isEmpty) return this;
      return addAll(newPoints);
    }
    throw "MultiPoint.difference ${geom.runtimeType} not implemented";
  }
  
  bool intersects(Geometry geom) => any(geom.intersects);
  bool encloses(Geometry geom) => any(geom.encloses);
  bool touches(Geometry geom) {
    bool foundTouch;
    if (geom is Point) {
      return any(geom.encloses);
    }
    for (var p in this) {
      var isect = geom.intersection(p);
      if (isect == null) continue;
      if (geom is Linear) {
        if (isect == geom.start || isect == geom.end) {
          foundTouch = true;
        } else {
          return false;
        }
      }
      if (geom is Planar) {
        if (geom.boundary.encloses(isect)) {
          foundTouch= true;
        } else {
          return false;
        }
      }
    }
    return foundTouch;
  }
  
  MultiPoint add(Nodal geom) {
    return new MultiPoint([_geometries, [geom]].expand((i) => i));
  }
  
  MultiPoint addAll(Iterable<Point> points) {
    return new MultiPoint([_geometries, points].expand((i) => i));
  }
}