part of geometry;

/**
 * A [Ring] is a closed [Linestring]
 */
class Ring extends GeometryCollection<Point> implements Planar {
  
  Ring(Iterable<Point> vertices) : super(vertices, false) {
    if (vertices.length <= 3) throw new InvalidGeometry("A ring must have at least three distinct coordinates");
    if (!Linestring._isClosed(vertices)) {
      vertices = [vertices, [vertices.first]].expand((i) => i);
    }
    GeometryList selfIntersections = 
        alg.bentleyOttmanIntersections(boundary.segments.toSet(), ignoreAdjacencies: true);        
    if (selfIntersections.isNotEmpty) {
      throw new InvalidGeometry("A ring cannot intersect itself \n"
                                "\t(intersections: $selfIntersections)");
    }
  }
  
  factory Ring.fromSegments(Iterable<LineSegment> segments) {
    for (var i in range(1, segments.length)) {
      final i_adjacent = 
          segments.elementAt(i - 1).end == segments.elementAt(i).start;
      if (!i_adjacent) {
        throw new InvalidGeometry("All segments must be adjacent.\n\tSegments:\n\t\t"
                                  "${segments.join("\n\t\t")}");
      }
    }
    if (segments.first.start != segments.last.end) {
      throw new InvalidGeometry("Segments must form a closed ring\n"
                                "\tSegments: $segments");
    }
    final ring_vertices = new List.from(segments.map((s) => s.start));
    ring_vertices.add(segments.last.end);
    return new Ring(ring_vertices);
  }
  
  Linestring get boundary => new Linestring(this);
  
  Point get centroid  => boundary.centroid;
  Bounds get bounds   => boundary.bounds;
  double get area     => tesselate().fold(0.0, (s, tessel) => s + tessel.area);
  
  Ring translate({double dx: 0.0, double dy: 0.0}) 
      => new Ring(map((v) => v.translate(dx: dx, dy: dy)));
  
  Ring rotate(double dt, {Point origin: null}) {
    if (origin == null) origin = centroid;
    return new Ring(map((v) => v.rotate(dt, origin: origin)));
  }
  
  Ring scale(double ratio, {Point origin: null}) {
    if (origin == null) origin = centroid;
    return new Ring(map((v) => v.scale(ratio, origin: origin)));
  }
  
  Ring permute([int i = 1]) {
    i = i % (length - 1);
    if (i == 0) return this;
    //remove the duplicated vertex;
    var boundary = this.boundary.take(length - 1);
    var rotatedBoundary = 
        [boundary.skip(i), boundary.take(i)]
        .expand((i) => i).toList();
    //And close the linestring.
    rotatedBoundary.add(rotatedBoundary[0]);
    return new Ring(rotatedBoundary);
  }
  
  /**
   * Returns the [Ring] with boundary consisting of all the segments in the [:boundary:]
   * between start and end and closed by a final segment between [:end:] and [:start:].
   * 
   * A [RangeError] is thrown if there are fewer than three elements in the ring, or if
   * either the [:start:] or [:end:] point is not the index of a boundary vertex.
   * An [InvalidGeometry] is trhown if the resulting subring would intersect itself.
   */
  Ring subring(int start, int end) {
    if ((start - end).abs() < 2) {
      throw new RangeError("Cannot form subring between adjacent vertices");
    }
    if (start < 0 || start >= length
        || end < 0 || end >= length) {
      throw new RangeError("Index out of range");
    }
    final boundary = this.boundary.toList();
    var includeVerts = new List();
    if (start < end) {
      includeVerts.addAll(boundary.sublist(start, end + 1));
    } else {
      includeVerts.addAll(boundary.sublist(start));
      includeVerts.addAll(boundary.sublist(0, end + 1));
    }
    includeVerts.add(boundary[start]);
    try {
      return new Ring(includeVerts);
    } on InvalidGeometry {
      throw new InvalidGeometry("Subring between $start and $end is self-intersecting");
    }
  }
  
  Geometry _segmentIntersection(LineSegment lseg, {double tolerance: 1e-15}) {
    var boundaryIntersections = new GeometryList<Point>();
    
    if (_enclosesPoint(lseg.start, tolerance: tolerance)) 
      boundaryIntersections.add(lseg.start);
    if (_enclosesPoint(lseg.end, tolerance: tolerance))   
      boundaryIntersections.add(lseg.end);
    for (var seg in boundary.segments) {
      var segIntersection = seg.intersection(lseg, tolerance: tolerance);
      if (segIntersection is Point)
        boundaryIntersections.add(segIntersection);
      if (segIntersection is LineSegment)
        boundaryIntersections.addAll(segIntersection.toLinestring());
    }
    
    if (boundaryIntersections.isEmpty) return null;
    
    boundaryIntersections
      .sort((p1, p2) => Comparable.compare(p1.distanceToSqr(lseg.start), 
                                           p2.distanceToSqr(lseg.start)));
    boundaryIntersections = boundaryIntersections
      .fold(new GeometryList(), (intersections, p) {
          append(Geometry g) { intersections.add(g); return intersections; }
          
          if (intersections.isEmpty) return append(p);
          var prev = intersections.removeLast();
          var seg;
          if (prev is Point) {
            if (prev.equalTo(p, tolerance: tolerance)) return append(prev);
            seg = new LineSegment(prev, p);
          }
          if (prev is LineSegment) {
            if (prev.encloses(p, tolerance: tolerance)) return append(prev);
            if (prev.end.equalTo(p, tolerance: tolerance)) {
              seg = new LineSegment(prev.start, p);
            }
          }
          if (_enclosesPoint(seg.centroid)) return append(seg);
          intersections.addAll([prev, p]);
          return intersections;
        });
    return (boundaryIntersections.length == 1) 
        ? boundaryIntersections.single 
        : boundaryIntersections;
  }
  
  Geometry _tesselIntersection(Tessel tesl, {double tolerance: 1e-15}) {
    return tesselate()
        .map((t) => tesl.intersection(t, tolerance: tolerance))
        .fold(null, (result, i) => result == null ? intersection : result.union(i, tolerance: tolerance));
  }
  
  Geometry _ringIntersection(Ring r, {double tolerance: 1e-15}) {
    
  }
  
  Geometry intersection(Geometry geom, {double tolerance: 1e-15}) {
    if (!mbrIntersects(geom, tolerance: tolerance)) return null;
    if (geom is Point) {
      if (_enclosesPoint(geom, tolerance: tolerance)) return geom;
    }
    if (geom is LineSegment) {
      return _segmentIntersection(geom, tolerance: tolerance);
    }
    if (geom is Linestring) {
      var intersections = new GeometryList<LineSegment>();
      for (var seg in geom.segments) {
        final segIntersection = intersection(seg, tolerance: tolerance);
        if (segIntersection is LineSegment) 
          intersections.add(segIntersection);
        if (segIntersection is GeometryList)
          intersections.addAll(segIntersection);
      }
      if (intersections.isEmpty) return null; 
      intersections.simplify(tolerance: tolerance);
      return (intersections.length == 1) ? intersections.single : intersections;
    }
    if (geom is Tessel) {
      return _tesselIntersection(geom, tolerance: tolerance);
    }
    if (geom is Ring) {
      throw "NotImplemented";
    }
    return geom.intersection(this, tolerance: tolerance);
  }
  
  bool _enclosesPoint(Point p, {double tolerance: 1e-15}) {
    //A ray from the point to infinity (or at least to outside the bounds of the ring)
    // along the positive horizontal axis 
    final rayToInfinity = new LineSegment(
        p, 
        new Point(x:bounds.right + 1.0, y: p.y));
    Geometry rayIntersection(LineSegment lseg) => 
        rayToInfinity.intersection(lseg, tolerance: tolerance);
    //If the line intersects the boundary at one of the corners of the ring,
    //save the corner we intersected at.
    Point prevCorner;
    int intersectionCount = 0;
    final boundarySegs = boundary.segments;
    for (var i in range(boundarySegs.length)) {
      var seg = boundarySegs.elementAt(i);
      var segIntersection = rayIntersection(seg);
      if (segIntersection is Point) {
        //If the intersection point is at the last corner, the ray has intersected
        //the polygon at one of the vertices. We only want to count the intersection once.
        if (segIntersection.equalTo(prevCorner, tolerance: tolerance)) {
          prevCorner = null;
          continue;
        }
        if (segIntersection.equalTo(seg.end, tolerance: tolerance)) {
          prevCorner = segIntersection;
        } else {
          prevCorner = null;
        }
        intersectionCount ++;
      } else if (segIntersection is LineSegment) {
        final savPrevCorner = prevCorner;
        if (segIntersection.encloses(seg.end, tolerance: tolerance)) {
          prevCorner = seg.end;
          intersectionCount++;
        }
        if (segIntersection.encloses(savPrevCorner, tolerance: tolerance)) {
          //We've already counted this segment
          continue;
        }
        intersectionCount ++;
      }
    }
    return intersectionCount % 2 != 0;
  }
  
  /**
   * Checks whether the current [Ring] completely encloses the given [LineSegment],
   * up to a given [:tolerance:].
   * The algorithm has a worst case complexity of O(n).
   */
  bool _enclosesLineSegment(LineSegment lseg, {double tolerance: 1e-15}) {
    if (!_enclosesPoint(lseg.start)) return false;
    if (!_enclosesPoint(lseg.end)) return false;
    for (var seg in boundary.segments) {
      var intersection = lseg.intersection(seg, tolerance: tolerance);
      if (intersection is LineSegment) {
        //The line runs along one of the edges of the ring. We must enclose the segment
        return true;
      }
      if (intersection is Point) {
        //If the intersection point is the start or end point of the current boundary segment,
        //then we just touch the edge. Otherwise, the segment must leave the ring for a portion of it's length
        if (intersection.equalTo(seg.start, tolerance: tolerance)) continue;
        if (intersection.equalTo(seg.end, tolerance: tolerance))   continue;
        return false;
      }
    }
    //We only intersect at the endpoints of the line.
    //If we enclose the centroid, we enclose the linesegment
    return _enclosesPoint(lseg.centroid, tolerance: tolerance);
  }
  
  /**
   * `true` if the [Ring] completely encloses the given [Geometry], up to a specified [:tolerance:]
   * Worst case complexity (when the argument is a [Linestring] or [Ring] is O(n^2).
   */
  bool encloses(Geometry geom, {double tolerance: 1e-15}) {
    if (!mbrIntersects(geom)) return false;
    if (geom is Point) return _enclosesPoint(geom, tolerance: tolerance);
    
    if (geom is LineSegment) {
      return _enclosesLineSegment(geom, tolerance: tolerance);
    }
    if (geom is Linestring) {
      //FIXME: There should be O(n*logn) algo here
      //Complexity: O(n^2)
      return geom.segments
             .every((s) => _enclosesLineSegment(s, tolerance: tolerance));
    }
    if (geom is Ring) {
      //FIXME: There should be O(n*logn) algo here.
      //Complexity: O(n^2);
      return geom.boundary.segments
             .every((s) => _enclosesLineSegment(s, tolerance: tolerance));
    }
    if (geom is GeometryList) {
      return geom.every((c) => encloses(c, tolerance: tolerance));
    }
    if (geom is Polygon) {
      return encloses(geom.outer);
    }
    throw "Unexpected geometry type: ${geom.runtimeType}";
  }

  bool intersects(Geometry geom, {double tolerance: 1e-15}) {
    //There are some significant speedups to be made by overriding this here.
    if (geom is Nodal) {
      return _enclosesPoint(geom.toPoint(), tolerance: tolerance);
    }
    if (geom is LineSegment) {
      final enclosesStart = _enclosesPoint(geom.start);
      final enclosesEnd   = _enclosesPoint(geom.end);
      if (enclosesStart || enclosesEnd) return true;
      //We could still intersect the segment if any of the boundary segments intersect the segment
      return boundary.segments.any((s) => geom.intersects(s, tolerance: tolerance));
    }
    if (geom is Linestring) {
      return geom.segments.any((s) => intersects(s, tolerance: tolerance));
    }
    if (geom is Ring) {
      //If the geometry is a ring, it intersects the current ring iff:
      //1. We enclose the ring
      //2. The boundary of the ring intersects our boundary.
      
      //(2) should be easier to check? It's O(n * logn)
      //Whereas enclosing is O(n^2) and needs to be revisited.
      final bndary = geom.boundary;
      return boundary.intersects(bndary, tolerance: tolerance)
          || encloses(bndary, tolerance: tolerance);
    }
    if (geom is GeometryList) {
      return geom.any((g) => intersects(g, tolerance: tolerance));
    }
    return geom.intersects(this, tolerance: tolerance);
  }
  
  //Cache the tesselation if we produce one.
  Set<Tessel> _cachedTesselation = null;
  
  /**
   * Splits the ring up into a set of [Tessel]s
   */
  Set<Tessel> tesselate() {
    if (_cachedTesselation != null) return _cachedTesselation;
    _cachedTesselation = new Set<Tessel>();
    Ring simpleRing = simplify();
    final boundary = simpleRing.boundary.toList(growable: false);
    if (boundary.length == 4) {
      _cachedTesselation.add(new Tessel(boundary[0], boundary[1], boundary[2]));
      return _cachedTesselation;
    }
    final a = boundary[0];
    for (var i in range(2, length)) {
      var splitSegment = new LineSegment(a, boundary[i]);
      if (encloses(splitSegment)) {
        print(splitSegment);
        print(subring(0, i));
        _cachedTesselation.addAll(subring(0, i).tesselate());
        _cachedTesselation.addAll(subring(i, 0).tesselate());
        return _cachedTesselation;
      }
    }
    throw new InvalidGeometry("Could not split ring at any point");
  }
  
  Ring simplify({double tolerance: 1e-15}) {
    var simplifyBoundary = boundary.simplify(tolerance: tolerance);
    //We can further simplify the ring if the points around the start of the ring
    //are colinear
    while (colinear(simplifyBoundary[simplifyBoundary.length - 2], 
                    simplifyBoundary[0], 
                    simplifyBoundary[1])) {
      //remove the endpoints
      simplifyBoundary = 
          new Linestring(simplifyBoundary
              .take(simplifyBoundary.length - 1)
              .skip(1));
      //And close the boundary
      simplifyBoundary = simplifyBoundary.append(simplifyBoundary.first); 
    }
    return new Ring(simplifyBoundary);
  }
  
  Polygon toPolygon() => new Polygon(outer: this);
  
  bool operator ==(Object o) {
    if (o is! Ring) return false;
    final r = o as Ring;
    if (r.length != length) return false;
    return range(length).every((i) => this[i] == r[i]);
  }
  
  int get hashCode {
    var result = 59;
    for (var v in this) {
      result += result * 59 + v.hashCode;
    }
    return result;
  }
  
  String toString() => "Ring[${this.join(", ")}]";
}