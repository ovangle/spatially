part of geom.base;

class GeometryList<T extends Geometry> extends Geometry with ListMixin<T> {
  List<T> _geometries;

  GeometryList._(List<T> this._geometries,
                 GeometryFactory factory)
      : super._(factory);

  Coordinate get coordinate {
    if (isEmptyGeometry)
      throw new GeometryError("Empty geometry has no coordinates");
    return _geometries[0].coordinate;
  }

  Array<Coordinate> get coordinates {
    List<Coordinate> coords = new List<Coordinate>();
    for (var geom in _geometries) {
      coords.addAll(geom.coordinates);
    }
    return new Array<Coordinate>.from(coords);
  }

  /**
   * A [GeometryList] is empty if all of it's component
   * geomtries are empty.
   */
  bool get isEmptyGeometry =>
      _geometries.every((g) => g.isEmptyGeometry);

  int get dimension =>
      _geometries.fold(
          dim.EMPTY,
          (d, g) => math.max(d, g.dimension));

  int get boundaryDimension =>
      _geometries.fold(
          dim.EMPTY,
          (d, g) => math.max(d, g.boundaryDimension));

  Envelope _computeEnvelope() =>
      fold(new Envelope.empty(),
          (env, g) => env.expandedToIncludeEnvelope(g.envelope));

  Geometry get boundary {
    throw new GeometryError("A GeometryList has no boundary");
  }

  double get topologicalLength =>
      fold(0.0, (l, g) => l + g.topologicalLength);

  double get topologicalArea =>
      fold(0.0, (a, g) => a + g.topologicalArea);

  bool equalsExact(Geometry other, [double tolerance = 0.0]) {
    if (other is GeometryList) {
      if (length != other.length) return false;
      return range(length).every(
          (i) => this[i].equalsExact(other[i], tolerance)
       );
    }
    return false;
  }

  GeometryList<T> get copy {
    GeometryList<T> geomList = factory.createEmptyGeometryList();
    geomList.addAll(map((g) => g.copy));
    return geomList;
  }

  void normalize() {
    forEach((g) => g.normalize());
    sort();
  }

  int _compareToSameType(GeometryList<T> geomList,
                         Comparator<CoordinateSequence> comparator) {
    int l1 = length;
    int l2 = geomList.length;
    int i = 0;
    while (i < l1 && i < l2) {
      var cmp = this[i].compareTo(geomList[i], comparator);
      if (cmp != 0) return cmp;
      i++;
    }
    if (i < l1) return 1;
    if (i < l2) return -1;
    return 0;

  }

  /**
   * Checks whether the argument geometry is a component, or a subcomponent of `this`.
   */
  bool hasComponent(Geometry geom) =>
      any((g) => identical(geom, g) || (g is GeometryList && g.hasComponent(geom)));

  // Implementation of ListMixin
  int get length => _geometries.length;
      set length(int value) {
        _geometries.length = value;
      }
  Geometry operator [](int i) => _geometries[i];
  void operator []=(int i, Geometry value) {
   _geometries[i] = value;
  }

  String toString() {
    var wktCodec = new wkt.WktCodec(factory);
    return wktCodec.encoder.convert(this);
  }
}