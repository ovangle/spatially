part of geom.base;

class Point extends Geometry {
  /**
   * The [Coordinate] wrapped by this [Point]
   */
  CoordinateSequence _coords;
  Point._(CoordinateSequence this._coords, GeometryFactory factory)
      : super._(factory);

  Coordinate get coordinate =>
      isNotEmptyGeometry ? _coords.first : null;

  bool get isEmptyGeometry => _coords.length == 0;

  bool get isSimple => true;

  int get dimension => dim.POINT;

  int get boundaryDimension => dim.EMPTY;

  Geometry get copy => factory.createPoint(new Coordinate.copy(coordinate));

  Geometry get reversed => copy;

  Geometry get boundary =>
      factory.createEmptyGeometryList();

  Array<Coordinate> get coordinates => _coords.toArray();

  Envelope _computeEnvelope() {
    Envelope env = new Envelope.empty();
    if (isEmptyGeometry) {
      return env;
    }
    return env.expandToCoordinate(this.coordinate);
  }

  bool equalsExact(Geometry other, [double tolerance = 0.0]) {
    if (other is Point) {
      if (isEmptyGeometry && other.isEmptyGeometry) return true;
      if (isEmptyGeometry || other.isEmptyGeometry) return false;
      if (tolerance > 0) {
        return coordinate == other.coordinate;
      }
      return coordinate.equals2d(other.coordinate, tolerance);
    }
    return false;
  }


  void normalize() {
    // a point is always normalized
  }

  int _compareToSameType(Point other, Comparator<CoordinateSequence> comparator) {
    return comparator(_coords, other._coords);
  }


}