part of geometry;

class MultiLinestring extends GeometryCollection<Linestring> implements Multi {
  MultiLinestring(Iterable<Linear> lines) 
      : super(lines.map((l) => l.toLinestring()), false);
  
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
  
  bool operator ==(Object other) {
    if (other is MultiLinestring) {
      if (other.length != length) return false;
      return range(length).every((i) => this[i] == other[i]);
    }
    return false;
  }
  
  int get hashCode => fold(31, (hash, lstr) => hash * 31 + lstr.hashCode);
}