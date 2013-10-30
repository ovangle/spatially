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
   */
  Linestring([Iterable<Point> vertices]) : super((vertices != null) ? vertices : [], false);
  
  /**
   * Constructs a [Linestring] from a list of adjacent lines, connected by their endpoints.
   * Throws an [InvalidGeometry] if there are two non-contiguous segments in the list.
   * 
   * If [:reverse:] is `true`, then elements of [:lines:] will be reversed as necessary
   * to ensure that the resulting linestring is valid.
   */
  factory Linestring.fromLines(Iterable<Linear> lines, {bool reverse: false}) {
    return lines.fold(
        new Linestring(), 
        (lstr, seg) => lstr.concat(seg, reverse: reverse));
  }
  
  /**
   * Return the linestring obtained by appending the given [Nodal] geometry
   * to the list of vertices.
   * 
   * If [:preserve_closure:] is `true` and the linestring is closed,
   * then the returned [Linestring] will also be closed.
   */
  Linestring append(Nodal p, {bool preserve_closure: false}) =>
      insert(length, p, preserve_closure: preserve_closure);
  
  /**
   * Insert the given point into the linestring at index [:i:].
   * 
   * If [:preserve_closure:] is `true` and the linestring is
   * closed, then the resulting linestring will be closed
   */
  Linestring insert(int i, Nodal p, {bool preserve_closure : false}) {
    if (i < 0 || i > length) {
      throw new RangeError("Not a valid index into the linestring: $i");
    }
    if (preserve_closure) {
      var verts = _geometries.take(length - 1).toList();
      if (i == 0 && preserve_closure && _isClosed(this)) {
          verts.insert(0, p.toPoint());
      } else if (i == length && preserve_closure && _isClosed(this)) {
          verts.add(p.toPoint());
      } else if (i == length) {
        verts.add(p);
      } else {
        verts.insert(i, p);
      }
      verts.add(verts[0]);
      return new Linestring(verts);
    } else {
      var verts = _geometries.toList();
      if (i < length) {
        verts.insert(p, i);
      } else {
        verts.add(p);
      }
      return new Linestring(verts);
    }
  }
  
  /**
   * Concatenates a [Linear] geometry onto the end of this geometry
   * Raises an [InvalidGeometry] if the start point of the line is not
   * equal to the endpoint of the linestring.
   * 
   * If [:tolerance:] is given, the argument's start can be a maximum of [:tolerance:] units 
   * away from the endpoint when matching against `this.end`. 
   * If the endpoints are seperated by a distance less than [:tolerance:], 
   * `this`.end will be used as the connecting point.
   * 
   * If [:reverse:] is `true`, then [:line:] may be reversed in an attempt
   * to ensure that it remains adjacent to the endpoint.
   */
  Linestring concat(Linear line, {double tolerance: 0.0, bool reverse: false}) {
    if (isEmpty) return line.toLinestring();
    
    if (reverse && line.end.equalTo(end, tolerance: tolerance)) {
      return concat(line.reversed);
    }
    if (!line.start.equalTo(end, tolerance: tolerance)) {
      throw new InvalidGeometry("Line must be adjacent at one of it's endpoints\n"
                                "\tLine: $line");
    }
    return new Linestring([_geometries, line.toLinestring().skip(1)].expand((i) => i));
  }
  
  
  /**
   * The geometric length of `this`
   */
  double get span => segments.fold(0.0, (span, seg) => span + seg.span);
  
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
  Geometry intersection(Geometry geom) {
    if (!boundsIntersects(geom)) return null;
    
    if (geom is Point) {
      return segments.map((seg) => seg.intersection(geom))
                     .firstWhere((intersection) => intersection != null, orElse: () => null);
    }
    
    if (geom is Linear) {
      for (var seg in segments.where((s) => s.encloses(geom))) {
        return geom;
      }
      Set segs = new Set.from(segments)
          .union(geom.toLinestring().segments.toSet());
      
      final intersections = new GeometryList.from(
          alg.bentleyOttmanIntersections(segs, ignoreAdjacencies: true), 
          growable: false);
      return intersections.isNotEmpty ? intersections : null;
    }
    
    return geom.intersection(this);
  }
  
  Point get centroid {
    //Only count each vertex once, even if we're closed
    Iterable<Point> vertices = _isClosed(this) ? skip(1) : this;

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
    if (geom is Point) {
      return segments.any((s) => s.encloses(geom, tolerance: tolerance));
    }
    
    if (geom is LineSegment) {
      final simplified = simplify(tolerance: tolerance);
      return segments.any((s) => s.encloses(geom));
    }
    
    if (geom is Linestring) {
      return geom.segments.every((s) => encloses(s));
    }
    
    return false;
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
      return touches(geom.start, tolerance: tolerance)
          || touches(geom.end, tolerance: tolerance);
    }
    if (geom is Planar || geom is GeometryList) {
      return geom.touches(this, tolerance: tolerance);
    }
    throw new InvalidGeometry("Unreognised geometry type: ${geom.runtimeType}");
  }
  
  Linestring toLinestring() => this;
  
  /**
   * Returns a new [Linestring] which passes through each of the vertices in the opposite direction
   */
  Linestring get reversed => new Linestring(_geometries.reversed);
  
  /**
   * Returns a new linestring where:
   * 1. All adjacent vertices which are equal to within the given tolerance
   *    are collapsed into a single point
   * 2. For every triple of vertices a, b, c if the triangle formed with base ac
   *    and apex b has height less than tolerance, b is removed from the linestring
   */
  Linestring simplify({double tolerance:1e-15}) {
    if (isEmpty) return this;
    //The vertices in the linestring which are equal to the previous vertex
    final nonDups = [this[0]];
    nonDups.addAll(
        range(1, length)
        .where((i) => this[i].notEqualTo(this[i - 1], tolerance: tolerance))
        .map((i) => this[i])
    );
    final nonColinear = [nonDups[0]];
    for (int i=1; i < nonDups.length - 1; i++) {
      final lseg = new LineSegment(nonDups[i - 1], nonDups[i + 1]);
      if (!lseg.encloses(nonDups[i], tolerance: tolerance)) {
        nonColinear.add(nonDups[i]);
      }
    }
    nonColinear.add(nonDups[nonDups.length - 1]);
    return new Linestring(nonColinear);
  }
  
  String toString() => "Linestring($_geometries)";
}