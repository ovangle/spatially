part of geometry;

class MultiPolygon extends GeometryCollection<Polygon> implements Multi {
  MultiPolygon(Iterable<Planar> planes)
      : super(planes.map((p) => p.toPolygon()), false);
  
  Point get centroid {
    if (isEmpty) 
      throw new InvalidGeometry("Empty MultiPolygon has no centroid");
    final cx = fold(0.0, (sum, poly) => sum + (poly.area > 0) ? poly.centroid.x / poly.area : 0.0);
    final cy = fold(0.0, (sum, poly) => sum + (poly.area > 0) ? poly.centroid.y / poly.area : 0.0);
    return new Point(x: cx / length, y: cy / length);
  }
  
  MultiPolygon translate({double dx: 0.0, double dy: 0.0}) {
    return new MultiPolygon(map((g) => g.translate(dx: dx, dy: dy)));
  }
  
  MultiPolygon rotate(double dt, {Point origin}) {
    if (isEmpty) return this;
    if (origin == null) origin = centroid;
    return new MultiPolygon(map((g) => g.rotate(dt, origin: origin)));
  }
  
  MultiPolygon scale(double ratio, {Point origin}) {
    if (isEmpty) return this;
    if (origin == null) origin = centroid;
    return new MultiPolygon(map((g) => g.scale(ratio, origin: origin)));
  }
  
  bool encloses(Geometry geom) => any(geom.enclosedBy);
}