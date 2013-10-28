part of geometry;

class Linestring extends GeometryCollection<Point> 
                 implements Linear {
  
  Point get start => first;
  Point get end   => last;
  
  static bool _isClosed(Iterable<Point> vertices) {
    return vertices.length > 3
        && vertices.first == vertices.last;
  }
  
  GeometryList<Point> get mutableCopy {
    return new GeometryList<Point>.from(this);
  }
  
  /**
   * Creates a linestring from an iterable of [Point]s.
   * If dart checked mode is active, raises an [InvalidGeometry]
   * if:
   * 1. the [Linestring] has length <= 2,
   */
  Linestring(Iterable<Point> vertices) : super(vertices, false) {
    assert(() { //#ifdef DEBUG
    if (vertices.length < 2) {
      throw new InvalidGeometry("Linestring with fewer than 2 vertices");
    }
    Set<LineSegment> segs = new Set.from(segments);
    return true;
}()); // #endif
  }
  
  Linestring append(Nodal p) {
    final verts = _geometries.toList();
    verts.add(p);
    return new Linestring(verts);
  }
  
  /**
   * Concatenates a [Linear] geometry onto the end of this geometry
   * Raises an [InvalidGeometry] if the start point of the line is not
   * equal to the endpoint of the linestring.
   */
  Linestring concat(Linear line, {double tolerance: 1e-15, bool reverse: false}) {
    var lstr = this;
    if (reverse) {
      if (line.end.equalTo(end, tolerance: tolerance)) {
        line = line.reversed();
      } else if (start.equalTo(line.start, tolerance: tolerance)) {
        lstr = lstr.reversed();
      }
    }
    if (!line.start.equalTo(lstr.end, tolerance: tolerance)) {
      throw new InvalidGeometry("Cannot concatenate non-contiguous linear geometry $line");
    }
    final verts = lstr._geometries.toList();
    verts.addAll(line.toLinestring().skip(1));
    return new Linestring(verts);
  }
  
  /**
   * Constructs a [Linestring] from a list of segments, connected by their endpoints.
   * Throws an [InvalidGeometry] if there are two non-contiguous segments in the list.
   */
  factory Linestring.fromSegments(Iterable<LineSegment> segments) {
    List<Point> vertices = new List<Point>();
    for (var seg in segments) {
      if (vertices.isEmpty) {
        vertices.add(seg.start);
      } else if (vertices.last != seg.start) {
        throw new InvalidGeometry("All segments in linestring must be connected end to start");
      }
      vertices.add(seg.end);
    }
    return new Linestring(vertices);
  }
  
  Iterable<Point> get vertices => this;
  
  double get span {
    var len = 0.0;
    for (var i in range(length - 1)) {
      len += this[i].distanceTo(this[i+1]);
    }
    return len;
  }
  /*
  double get geodesicSpan {
    if (length < 2)
      throw new StateError('Linestring with fewer than 2 vertices');
    double len = 0.0;
    for (var i in range(length - 1)) {
      len += this[i].geodesicDistanceTo(this[i+1]);
    }
    return len;
  }
  */
 
  /**
   * Iterates over the segments formed between each adjacent pair of vertices
   * in the [Linestring]
   */
  Iterable<LineSegment> get segments =>
     range(length - 1).map((i) => new LineSegment(this[i], this[i + 1]));
  
  /**
   * [:intersection:] returns the set of intersections with the other linestring.
   * Self-intersections of both linestring are included in the result set.
   * 
   * The elements of the GeometryList will be:
   * --A [LineSegment], if any of the segments of this, or of other are coincident for 
   *   any part of their length; or
   * --A [Point] if the the segment intersects another segment at a single point
   */
  GeometryList intersection(Geometry geom, {double tolerance: 1e-15}) {
    if (!mbrIntersects(geom, tolerance: tolerance)) return null;
    if (geom is Point) {
      for (var seg in segments) {
        var isect = seg.intersection(geom, tolerance: tolerance);
        if (isect != null) return isect;
      }
      return null;
    }
    if (geom is LineSegment) {
      Set segs = segments.toSet();
      segs.add(geom);
      return new GeometryList.from(alg.bentleyOttmanIntersections(segs, ignoreAdjacencies: true));
    }
    if (geom is Linestring) {
      Set segs = segments.toSet();
      segs = segs.union((geom as Linestring).segments.toSet());
      return new GeometryList.from(alg.bentleyOttmanIntersections(segs, ignoreAdjacencies: true));
    }
    return geom.intersection(this);
  }
  
  Point get centroid {
    //Only count each vertex once, even if we're closed
    Iterable<Point> vertices = _isClosed(this) ? skip(1) : this;
    //Only count each vertex once, even if we're closed
    var ySum = vertices.fold(0.0, (sum, v) => sum + v.y);
    var xSum = vertices.fold(0.0, (sum, v) => sum + v.x);
    
    return new Point(
        x: xSum / (vertices.length),
        y: ySum / (vertices.length));
  }
  
  Linestring translate({double dx: 0.0, double dy: 0.0}) 
      => new Linestring(map((v) => v.translate(dx: dx, dy: dy)));
  
  Linestring scale(double ratio, {Point origin}) {
    if (origin == null) origin = centroid;
    return new Linestring(map((v) => v.scale(ratio, origin: origin)));
  }
  
  Linestring rotate(double dt, {Point origin}) {
    if (origin == null) origin = centroid;
    return new Linestring(map((v) => v.rotate(dt, origin: origin)));
  }
  
  bool encloses(Geometry geom, {double tolerance: 1e-15}) {
    if (geom is Point) return segments.any((s) => s.encloses(geom, tolerance: tolerance));
    if (geom is LineSegment) {
      final simplified = simplify(tolerance: tolerance);
      return segments.any((s) => s.encloses(geom));
    }
    if (geom is Linestring) {
      final lstr = geom as Linestring;
      return lstr.segments.every((s) => encloses(s));
    }
    return geom.encloses(this, tolerance: tolerance);
  }
  
  /**
   * Returns `true` if the geometry touches one of the endpoints of the [Geometry].
   * -- If [:geom:] is a [Nodal] geometry, true iff the geom is the start or end point.
   * -- If [:geom:] is a [Linear] geometry, true iff the geom's start or end point touches the current geometry
   * -- If [:geom:] is a [Planar] geometry, true iff [:start:] or [:end:] is a point on the [:boundary:].
   * -- If [:geom:] is a [GeometryList], truee iff the geometry touches any of the elements of [:geom:]
   * 
   * **NOTE**: Unlike other geometric relations, [:touches:] is not commutative.
   */
  bool touches(Geometry geom, {double tolerance: 1e-15}) {
    if (geom is Nodal) {
      return (start.equalTo(geom, tolerance: tolerance))
          || (end.equalTo(geom, tolerance: tolerance));
    }
    if (geom is Linear) {
      return touches((geom as Linear).start, tolerance: tolerance)
          || touches((geom as Linear).end, tolerance: tolerance);
    }
    if (geom is Planar || geom is GeometryList) {
      return geom.touches(this, tolerance: tolerance);
    }
    throw new InvalidGeometry("Unreognised geometry type: ${geom.runtimeType}");
  }
  
  Linestring toLinestring() => this;
  
  Linestring reversed() => new Linestring(_geometries.reversed);
  
  /**
   * Returns a new linestring where:
   * 1. All adjacent vertices which are equal to within the given tolerance
   *    are collapsed into a single point
   * 2. For every triple of vertices a, b, c if the triangle formed with base ac
   *    and apex b has height less than tolerance, b is removed from the linestring
   */
  Linestring simplify({double tolerance:1e-15}) {
    bool isDup(int i) {
      if (i == 0) return false;
      return this[i].equalTo(this[i-1], tolerance: tolerance);
    }
    bool inline(int i) {
      if (i == 0 || i == length - 1) return false;
      final test = this[i];
      
      var j = i - 1;
      while (j != 0) {
        if (isDup(j)) { j--; } else { break; }
      }
      
      var k = i + 1;
      while (k < length) {
        if (isDup(k)) { k++; } else { break; }
      }
      
      final lseg = new LineSegment(this[j], this[k]);
      return lseg.encloses(test, tolerance: tolerance);
    }
    return new Linestring( 
          range(length)
              .where((i) => !isDup(i))
              .where((i) => !inline(i))
              .map((i) => this[i]));
  }
  
  String toString() => "Linestring($_geometries)";
}