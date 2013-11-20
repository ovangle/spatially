part of geom.base;

class MultiLinestring extends GeometryList<Linestring> {
  
  MultiLinestring._(List<Linestring> linestrings,
                    GeometryFactory factory) : 
      super._(linestrings, factory);
  
  int get dimension => 1;
  
  bool get isClosed {
    if (isEmptyGeometry) return false;
    return every((l) => l.isClosed);
  }
  
  int get boundaryDimension =>
      isNotEmptyGeometry && isClosed ? dim.EMPTY : 0;
  
  Geometry get boundary => bnd.boundaryOf(this);
  
  bool equalsExact(Geometry geom, [double tolerance=0.0]) {
    if (geom is! MultiLinestring) return false;
    return super.equalsExact(geom, tolerance);
  }
  
}