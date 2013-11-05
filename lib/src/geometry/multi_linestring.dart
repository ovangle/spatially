part of geometry;

class MultiLinestring extends GeometryCollection<Linestring> implements Multi {
  MultiLinestring([Iterable<Linear> lines]) 
      : super(lines != null ? lines.map((l) => l.toLinestring()) : []);
  
  Point get centroid {
    if (isEmpty) {
      throw new InvalidGeometry("Empty MultiLinestring has no centroid");
    }
    
    final sumX = fold(0.0, (s, lstr) => s + lstr.centroid.x);
    final sumY = fold(0.0, (s, lstr) => s + lstr.centroid.y);
    
    return new Point(x: sumX / length, y: sumY / length);
  }
  
  MultiLinestring translate({double dx, double dy}) {
    return new MultiLinestring(map((g) => g.translate(dx: dx, dy: dy)));
  }
  
  MultiLinestring rotate(double dt, {Point origin}) {
    if (isEmpty) return this;
    if (origin == null) origin = centroid;
    return new MultiLinestring(map((g) => g.rotate(dt, origin: origin)));
  }
  
  MultiLinestring scale(double ratio, {Point origin}) {
    if (isEmpty) return this;
    if (origin == null) origin = centroid;
    return new MultiLinestring(map((g) => g.scale(ratio, origin: origin)));
  }
  
  bool contains(Linear item) => _geometries.contains(item.toLinestring());
  
  bool encloses(Geometry geom) {
    if (geom is Point) {
      return any(geom.enclosedBy);
    }
    if (geom is Linear) {
      final partialGeom = fold(geom, (part, lstr) => (part != null) ? part - lstr : null);
      return partialGeom == null;
    }
    if (geom is Planar) {
      return any((lstr) => lstr.encloses(geom.boundary));
    }
    if (geom is Multi) {
      return geom.every(encloses);
    }
  }
  
  bool operator ==(Object other) {
    if (other is MultiLinestring) {
      if (other.length != length) return false;
      return range(length).every((i) => this[i] == other[i]);
    }
    return false;
  }
  
  int get hashCode => fold(31, (hash, lstr) => hash * 31 + lstr.hashCode);
}