part of geom.base;

class MultiPolygon extends GeometryList<Polygon> {
  MultiPolygon._(List<Polygon> polys, 
                 GeometryFactory factory) :
    super._(polys, factory);
  
  int get dimension => 2;
  
  int get boundaryDimension => 1;
  
  Geometry get boundary {
    if (isEmptyGeometry) {
      return factory.createEmptyMultiLinestring();
    }
    var allRings = new List<Ring>();
    forEach((poly) {
      allRings.addAll(poly._rings);
    });
    return factory.createMultiLinestring(allRings);
  }
  
  bool equalsExact(Geometry geom, [double tolerance=0.0]){
    if (geom is! MultiPolygon) return false;
    return super.equalsExact(geom, tolerance);
  }
}