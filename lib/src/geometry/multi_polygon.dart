part of geometry;

class MultiPolygon extends GeometryCollection<Polygon> implements MultiGeometry {
  MultiPolygon(Iterable<Planar> planes)
      : super(planes.map((p) => p.toPolygon()), false);
}