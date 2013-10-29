part of geometry;

/**
 * A [GeometryList] is a possibly heterogeneous, mutable collection of geometries.
 */
class GeometryList<T extends Geometry> extends GeometryCollection<T> with ListMixin<T> {
   
      
  GeometryList<T> get mutableCopy {
    return new GeometryList<T>.from(this);
  }
  /**
   * Creates a new [GeometryList] with the given [:length:]
   */
  factory GeometryList([int length]) {
    if (length == null) {
      return new GeometryList.from([], growable: true);
    }
    return new GeometryList.from(new List<T>(length), growable: false);
  }
  
  GeometryList.from(Iterable<T> geometries, 
                    { bool growable: true}) 
      : super(new List.from(geometries), growable);
  
  
  
  //Implementation of Geometry
  Point get centroid {
    if (any((g) => g is Planar)) return _weightedCentroid;
    final sumCentroid = 
        fold(new Point(x: 0.0, y: 0.0),
              (curr, geom) => new Point(x: curr.x + geom.centroid.x,
                                                y: curr.y + geom.centroid.y));
    return new Point(x: sumCentroid.x / length,
                     y: sumCentroid.y / length);
  }
  
  Point get _weightedCentroid {
    //If any of our components are planar, then discard the non-planar geoms
    final planars = where((g) => g is Planar);
    final areas   = planars.map((g) => g.area);
    final totalArea = areas.fold(0.0, (t, a) => t + a);
    var c_x, c_y;
    for (var i in range(planars.length)) {
      final curr = planars.elementAt(i).centroid;
      final currArea = areas.elementAt(i);
      c_x += curr.x * currArea;
      c_y += curr.y * currArea; 
    }
    return new Point(x: c_x / totalArea,
                     y: c_y / totalArea);
  }
  
  Bounds get bounds {
    final geomBounds = map((g) => g.bounds);
    return new Bounds(
        bottom: geomBounds.fold(double.NEGATIVE_INFINITY, (curr, bounds) => math.max(curr, bounds.bottom)),
        top:    geomBounds.fold(double.INFINITY,          (curr, bounds) => math.min(curr, bounds.top)),
        left:   geomBounds.fold(double.NEGATIVE_INFINITY, (curr, bounds) => math.max(curr, bounds.left)),
        right:  geomBounds.fold(double.INFINITY,          (curr, bounds) => math.min(curr, bounds.right)));
  }

  
  GeometryList<T> translate({double dx: 0.0, double dy: 0.0}) 
      => new GeometryList<T>.from(map((g) => (g as Geometry).translate(dx: dx, dy: dy)));
  
  GeometryList<T> scale(double ratio, {Point origin : null}) {
    if (origin == null) origin = centroid;
    return new GeometryList<T>.from(map((g) => (g as Geometry).scale(ratio, origin: origin)));
  }
  
  GeometryList<T> rotate(double dt, {Point origin : null}) {
    if (origin == null) origin = centroid;
    return new GeometryList<T>.from(map((g) => g.rotate(dt, origin: origin)));
  }
  Geometry intersection(Geometry geom, {double tolerance: 1e-15}) {
    //If we're passed a point, return the intersection as a point
    if (geom is Point) {
      if (any((g) => g.intersects(geom))) return geom;
    }
    //For all other geometries, return a List of all the intersections
    //between self and other
    return new GeometryList.from(map((g) => g.intersection(geom)));
  }
  
  /**
   * A [GeometryList] encloses another [Geometry] iff at least one of it's components
   * completely enclose the [Geometry]. 
   * 
   */
  bool encloses(Geometry geom, {double tolerance: 1e-15}) {
    return any((g) => g.encloses(geom, tolerance: tolerance));
  }
  
  /**
   * Simplify for geometry lists does a couple of things, depending on the components
   * of the list.
   * 
   * The following simplifications are performed:
   * 1. Any [Geometry] which is enclosed by an adjacent [Geometry] in the list is removed.
   * 2. [Linear] geometries which are connected (up to [:tolerance:] end-to-start to 
   *    an adjacent [Linear] geometry in the list are converted into the [Linestring] 
   *    which encloses both components
   * 4. [Planar] geometries which intersect an adjacent [Planar] geometry in the list are converted
   *    into a single [Planar] geometry which encloses both components
   * 
   */
  GeometryList simplify({double tolerance: 1e-15}) {
    Geometry simplifyAdjacent(GeometryList geomlist, Geometry geom2) {
      var toAdd;
      if (geomlist.isEmpty) {
        toAdd = [geom2];
      } else {
        final prevGeom = geomlist.removeLast();
        if (prevGeom is Nodal) {
          toAdd = _mergeNodal(prevGeom, geom2, tolerance);
        } else if (prevGeom is Linear) {
          toAdd = _mergeLinear(prevGeom, geom2, tolerance);
        } else if (prevGeom is Planar) {
          toAdd =  _mergePlanar(prevGeom, geom2, tolerance);
        } else {
          toAdd = [(prevGeom as GeometryList).simplify(tolerance: tolerance)];
        }
      }
      geomlist.addAll(toAdd);
      return geomlist;
    }
    if (length < 2) return new GeometryList<T>.from(this);
    var simplifiedList = 
        new GeometryList<T>.from(
            fold(new GeometryList(), simplifyAdjacent)
            .map((g) => g.simplify())
        );
    print(simplifiedList);
    if (simplifiedList.length < length) {
      simplifiedList = simplifiedList.simplify(tolerance: tolerance);
    }
    return simplifiedList;
  }
  
  
  //Implementation of List<T>
  
  Geometry operator[](int i) => _geometries[i];
  void operator[]=(int i, Geometry geom) {
    _geometries[i] = geom;
  }

  int 
    get length => _geometries.length;
    set length(int value) {
      _geometries.length = value;
    }
   
  
  bool operator ==(Object other) {
    if (other is! GeometryList<T>) return false;
    var geomList = other as GeometryList<T>;
    if (geomList.length != length) return false;
    for (var i in range(length)) {
      if (this[i] != geomList[i]) return false;
    }
    return true;
  }
  
  String toString() {
    final sBuffer = new StringBuffer("GEOM_LIST[");
    for (var i in range(length)) {
      sBuffer.write(this[i].toString());
      if (i < length - 1) sBuffer.write(", ");
    }
    sBuffer.write("]");
    return sBuffer.toString();
  }
  
}
    
Iterable<Geometry> _mergeNodal(Nodal node, Geometry geom, double tolerance) {
  final geomEncloses = geom.encloses(node, tolerance: tolerance);
  if (geom.encloses(node, tolerance: tolerance)) return [geom];
  return [node, geom];
}
    
Iterable<Geometry> _mergeLinear(Linear line, Geometry geom, double tolerance) {
  if (geom is Nodal) {
    Point p = geom.toPoint();
    if (line.encloses(geom, tolerance: tolerance)) {
      return [line];
    }
  }
  if (geom is Linear) {
    Linestring lstr1 = line.toLinestring();
    Linestring lstr2 = geom.toLinestring();
    if (lstr1.end.equalTo(lstr2.start, tolerance: tolerance)) {
      return [lstr1.concat(lstr2)];
    }
    if (lstr2.encloses(lstr1, tolerance: tolerance)) return [lstr2];
    if (lstr1.encloses(lstr1, tolerance: tolerance)) return [lstr1];
  }
  if (geom is Planar) {
    if (geom.encloses(line, tolerance: tolerance)) return [geom];
  }
  return [line, geom];
}

Iterable<Geometry> _mergePlanar(Planar plane, Geometry geom, double tolerance) {
  if (geom is Nodal) {
    if (plane.encloses(geom.toPoint(), tolerance: tolerance)) 
      return [geom];
  }
  if (geom is Linear) {
    if (plane.encloses(geom.toLinestring(), tolerance: tolerance))
      return [geom];
  }
  if (geom is Planar) {
    final poly1 = plane.toPolygon();
    final poly2 = geom.toPolygon();
    if (poly1.intersects(poly2, tolerance: tolerance)) {
      return poly1.union(poly2, tolerance: tolerance);
    }
  }
  return [plane, geom];
}