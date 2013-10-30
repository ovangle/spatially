part of geometry;

class MultiLinestring extends GeometryCollection<Linestring> implements MultiGeometry {
  MultiLinestring(Iterable<Linear> lines) 
      : super(lines.map((l) => l.toLinestring()), false);
}