part of geom.base;

/**
 * Models an OGC style [Linestring].
 * 
 * A [Linestring] consists of a sequence of two or more vertices
 * along with all points along the linearly-interpolated curves
 * (line segments) between each pair of consecutive vertices.
 * 
 * Consecutive vertices may be equal and the linestring is allowed
 * to be self-intersecting. A linestring with exactly two identical
 * points is invalid.
 */
class Linestring extends Geometry {
  CoordinateSequence _coords;
  
  Linestring._(CoordinateSequence this._coords, 
               GeometryFactory factory)
    : super._(factory);
  
  Array<Coordinate> get coordinates => _coords.toArray();
  
  CoordinateSequence get coordinateSequence => _coords;
  
  Coordinate get coordinate => isNotEmptyGeometry ? _coords.first : null;
  
  int get dimension => dim.LINE;
  
  bool get isEmptyGeometry => _coords.isEmpty;
  
  int get boundaryDimension => 
      (isEmptyGeometry || isClosed) ? dim.EMPTY : dim.POINT;
  
  Geometry get boundary {
    //TODO: Linestring.boundary
    throw 'Unimplemented';
  }
        
  bool get isClosed => isNotEmptyGeometry 
                    && (_coords.first == _coords.last);
  bool get isRing => isClosed && isSimple;
  
  /**
   * The number of vertices in `this`.
   * For the topological length of the [Linestring], see [:tolologicalLength:]
   */
  int get length => _coords.length;
  
  Array<Point> get vertices {
    var verts = new Array<Point>(_coords.length);
    verts.setAll(0, _coords.map((c) => factory.createPoint(c)));
    return verts;
  }
 
  Point get startPoint {
    if (isEmptyGeometry) {
      throw new GeometryError("An empty linestring has no start point");
    }
    return factory.createPoint(_coords.first);
    
  }
      
  Point get endPoint {
    if (isEmptyGeometry) {
      throw new GeometryError("An empty linestring has no end point");
    }
    return factory.createPoint(_coords.last);
  }
 
  Point vertexAt(int i) => 
      factory.createPoint(_coords[i]);
  
  /**
   * The length of the [LineString]
   */
  double get topologicalLength =>
      cg_algorithms.linestringLength(_coords);
  
  Envelope _computeEnvelope() =>
      _coords.fold(
          new Envelope.empty(),
          (env, c) => env.expandToCoordinate(c));
  /**
   * A linestring which contains all [Point]s in `this`
   * in the reversed order
   */
  Linestring get reversed => 
      factory.createLinestring(_coords.reversed);
 
  /**
   * `true` iff the given coordinate is a vertex of `this`
   */
  bool isVertex(Coordinate c) => _coords.any(c.equals2d);
  
  Linestring get copy => 
      factory.createLinestring(_coords.clone());
  
  /**
   * A [Linestring] in normal form has the first point which
   * is not equal to it's reflected point less than (according to
   * the natural lexicographic ordering on coordinates) the reflected
   * point
   */
  void normalize() {
    var len = _coords.length;
    for (var i in range(len / 2)) {
      var j = len - i - 1;
      //skip equal points at both ends
      if (_coords[i] != _coords[j]) {
        if (_coords[i] > _coords[j]) {
          _coords.reverse();
        }
        return;
      }
    }
  }
  
  int _compareToSameType(Linestring lstr, Comparator<CoordinateSequence> comparator) {
    return comparator(_coords, lstr._coords);
  }
  
  bool equalsExact(Geometry geom, [double tolerance = 0.0]) {
    if (geom is Linestring) {
      if (length != geom.length) return false;
      return range(length)
          .every((i) => _coords[i].equals2d(geom._coords[i], tolerance));
    }
    return false;
  }
  
}