part of operation.distance;



class _Location {
  /**
  * A special value of [:segmentIndex:] used for locations inside
  * area geometries. These locations are not located on a segment, thus
  * do not have a [:segmentIndex:]
  */
  static const int INSIDE_AREA = -1;
  
  final Geometry component;
  final int segmentIndex;
  final Coordinate coordinate;
  
  /**
  * Create a [GeometryLocation] specifing a point in a geometry
  * If segmentIndex is not provided, assumed to be a point inside the
  * area of a geometry.
  */
  _Location(Geometry this.component, Coordinate this.coordinate, 
  [int this.segmentIndex=INSIDE_AREA]);
  
  /**
  * Test whether this location is a point inside an area geometry
  */
  bool get isInsideArea => segmentIndex == INSIDE_AREA;
}