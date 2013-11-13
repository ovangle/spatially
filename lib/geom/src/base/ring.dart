part of geom.base;

class Ring extends Linestring {
  Ring._(CoordinateSequence coords, GeometryFactory factory) :
      super._(coords, factory);
  
  //Rings do not have a boundary
  int get boundaryDimension => dim.EMPTY;
  
  bool get isClosed => isEmptyGeometry || super.isClosed;
  
  Geometry get reversed {
    return factory.createRing(_coords.reversed);
  }
  
  Ring get copy => 
      factory.createRing(_coords.map((c) => new Coordinate.copy(c)));
  
}