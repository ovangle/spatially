part of operation.distance;

Iterable<Linestring> extractLines(Geometry geom, {bool asLinestrings: false}) {
  if (geom is Ring && asLinestrings) {
    return [geom.factory.createLinestring(geom.coordinates)];
  } else if (geom is Linestring) {
    return [geom];
  } else if (geom is GeometryList) {
    return geom.expand(extractLines);
  }
  return [];
}

Iterable<Point> extractPoints(Geometry geom) {
  if (geom is Point) {
    return [geom];
  } else if (geom is GeometryList) {
    return geom.expand(extractPoints);
  }
  return [];
}

Map computeFacetDistance(Geometry g)