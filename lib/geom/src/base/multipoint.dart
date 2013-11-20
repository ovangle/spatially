part of geom.base;

class MultiPoint extends GeometryList<Point> {
  MultiPoint._(List<Point> points, GeometryFactory factory) 
      : super._(points, factory);
  
  int get dimension => 0;
  
  int get boundaryDimension => dim.EMPTY;
  
  Geometry get boundary =>
    factory.createEmptyGeometryList();
  
  bool get isValid => true;
  
  bool equalsExact(MultiPoint g, [double tolerance=0.0]) {
    if (g is! MultiPoint) return false;
    return super.equalsExact(g, tolerance);
  }
  
  Point operator[](int i) => super[i];
  void operator[]=(int i, Point p) {
    super[i] = p;
  }
}