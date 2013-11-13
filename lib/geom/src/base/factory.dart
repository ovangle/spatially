part of geom.base;

class GeometryFactory {
  final PrecisionModel precisionModel;
  final CoordinateSequenceFactory coordinateSequenceFactory;
  final int srid;
  
  /**
   * Create a new [GeometryFactory] with the given
   * [PrecisionModel], [CoordinateSequenceFactory] and spatial reference system identifier.
   */
  GeometryFactory([PrecisionModel precisionModel,
                   CoordinateSequenceFactory coordinateSequenceFactory,
                   int this.srid = 0])
      : this.precisionModel = 
            (precisionModel != null) 
            ? precisionModel 
            : new PrecisionModel(PrecisionModel.PREC_FLOATING),
        this.coordinateSequenceFactory = 
            (coordinateSequenceFactory != null) 
            ? coordinateSequenceFactory 
            : DefaultCoordinateSequence.factory;
  
  Point createEmptyPoint() {
    CoordinateSequence _coords = coordinateSequenceFactory(0);
    return new Point._(_coords, this);
  }
  
  Point createPoint(Coordinate coordinate) {
    precisionModel.makePreciseCoordinate(coordinate);
    CoordinateSequence _coords = coordinateSequenceFactory(1);
    _coords[0] = coordinate;
    return new Point._(_coords, this);
  }
  
  Linestring createEmptyLinestring([lb_rule.VertexInBoundaryRule boundaryRule]) {
    CoordinateSequence _coords = coordinateSequenceFactory(0);
    return new Linestring._(_coords, this);
  }
  
  Linestring createLinestring(Iterable<Coordinate> coords) {
    if (coords.length == 1) {
      throw new ArgumentError(
          "Invalid number of coordinates in linestring (1). "
          "Expected 0 or >= 2");
    }
    CoordinateSequence _coords = coordinateSequenceFactory(coords.length);
    _coords.setAll(0, coords);
    _coords.forEach(precisionModel.makePreciseCoordinate);
    return new Linestring._(_coords, this);
  }
  
  Ring createEmptyRing() {
    CoordinateSequence coords = coordinateSequenceFactory(0);
    return new Ring._(coords, this);
  }
  Ring createRing(Iterable<Coordinate> coords) {
    if (coords.length >= 1 && coords.length < 4) {
      throw new ArgumentError(
          "Invalid number of coordinates in ring (${coords.length}). "
          "Expected 0 or >= 2");
    }
    if (coords.isNotEmpty && coords.first != coords.last){
      throw new ArgumentError(
          "Coordinates must form a closed ring");
    }
    coords.forEach(precisionModel.makePreciseCoordinate);
    return new Ring._(coords, this);
  }
  
  Polygon createEmptyPolygon() {
    return new Polygon._(createEmptyRing(), new Array(0), this);
  }
  
  Polygon createPolygon(Ring shell, [Iterable<Ring> holes = const[]]) {
    if (holes.any((h) => h == null)) {
      throw new ArgumentError("Holes cannot contain null elements");
    }
    if (shell.isEmptyGeometry && holes.any((h) => h.isNotEmptyGeometry)) {
      throw new ArgumentError("Shell is empty but contains non-empty hole"); 
    }
    return new Polygon._(shell, new Array.from(holes), this);
  }
  
  GeometryList createEmptyGeometryList() {
    return new GeometryList._([], this);
  }
  
  GeometryList createGeometryList(Iterable<Geometry> geoms) {
    return new GeometryList._(new List<Geometry>.from(geoms), this);
  }
  
  MultiPoint createEmptyMultiPoint() {
    return new MultiPoint._([], this);
  }
  MultiPoint createMultiPoint(Iterable<MultiPoint> points) {
    return new MultiPoint._(new List<Point>.from(points), this);
  }
  
  MultiLinestring createEmptyMultiLinestring() {
    return new MultiLinestring._([], this);
  }
  MultiLinestring createMultiLinestring(Iterable<Linestring> linestrings) {
    return new MultiLinestring._(
        new List<Linestring>.from(linestrings), 
        this);
  }
  
  MultiPolygon createEmptyMultiPolygon() {
    return new MultiPolygon._([], this);
  }
  
  MultiPolygon createMultiPolygon(Iterable<Polygon> polys) {
    return new MultiPolygon._(
        new List<Polygon>.from(polys),
        this);
  }
}