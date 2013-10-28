part of geometry;

class Tessel extends Geometry implements Planar {
  final Point a;
  final Point b;
  final Point c;
  
  LineSegment get ab      => new LineSegment(a, b);
  LineSegment get bc      => new LineSegment(b, c);
  LineSegment get ca      => new LineSegment(c, a);
  
  Tessel(Point this.a, Point this.b, Point this.c) {
    assert(a != b && a != c && b != c);
    if (colinear(a,b,c)) {
      throw new InvalidGeometry("Cannot form tessel from collinear points ($a, $b, $c)");
    }
  }
  
  factory Tessel.fromEdges(LineSegment ab, LineSegment bc, LineSegment ca) {
    var a,b,c;
    if (ab.start.equalTo(ca.end)) {
      a = ab.start;
    } else {
      throw new InvalidGeometry("Segments $ab and $ca not adjacent");
    }
    if (bc.start.equalTo(ab.end)) {
      b = bc.start;
    } else {
      throw new InvalidGeometry("Segments $bc and $ab not adjacent");
    }
    if (ca.start.equalTo(bc.end)) {
      c = ca.start;
    } else {
      throw new InvalidGeometry("Segments $ca and $ab not adjacent");
    }
    return new Tessel(a, b, c);
  }
  
  Bounds get bounds {
    final ps = [a, b, c];
    return new Bounds(bottom: ps.map((p) => p.y).fold(double.INFINITY, math.min),
                      top:    ps.map((p) => p.y).fold(double.NEGATIVE_INFINITY, math.max),
                      left:  ps.map((p) => p.y).fold(double.INFINITY, math.min),
                      right:  ps.map((p) => p.x).fold(double.NEGATIVE_INFINITY, math.max));
                      
  }
  
  Point get centroid => new Point(x: (a.x + b.x + c.x) / 3,
                                  y: (a.y + b.y + c.y) / 3);
  
  Linestring get boundary => new Linestring([a, b, c, a]);
  
  Tessel translate({double dx: 0.0, double dy: 0.0}) 
      => new Tessel(a.translate(dx: dx, dy: dy),
                    b.translate(dx: dx, dy: dy),
                    c.translate(dx: dx, dy: dy));
  
  Tessel rotate(double dt, {Point origin : null}) {
    if (origin == null) origin = centroid;
    return new Tessel(a.rotate(dt, origin: origin),
                      b.rotate(dt, origin: origin),
                      c.rotate(dt, origin: origin));
  }
  
  Tessel scale(double ratio, {Point origin: null}) {
    if (origin == null) origin = centroid;
    return new Tessel(a.scale(ratio, origin: origin),
                      b.scale(ratio, origin: origin),
                      c.scale(ratio, origin: origin));
  }
  
  Tessel permuted([int i = 1]) {
    switch (i % 3) {
      case 0: 
        return this;
      case 1:
        return new Tessel(b, c, a);
      case 2:
        return new Tessel(c, a, b);
    }
  }
  
  double distanceTo(Geometry geom) {
    final ps = [a, b, c];
    return ps.map((p) => p.distanceTo(geom))
             .fold(0.0, math.min);
  }
 
  LineSegment get _base   => new LineSegment(a, b);
  double      get _height => _base.distanceTo(c);
  
  double get area => 0.5 * _base.span * _height;
  
  Geometry _segmentIntersection(LineSegment lseg, {double tolerance: 1e-15}) {
    final enclosesStart = _enclosesPoint(lseg.start, tolerance: tolerance);
    final enclosesEnd   = _enclosesPoint(lseg.end, tolerance: tolerance);
    
    if (enclosesStart && enclosesEnd) return lseg;
    final boundaryIntersections = 
        boundary.segments
                .map((s) => lseg.intersection(s, tolerance: tolerance))
                .where((s) => s != null)
                .toSet();
    switch(boundaryIntersections.length) {
      case 0: //No intersection
        return null;
      case 1: //One of the edges is a subsegment of lseg
        final intersection = boundaryIntersections.single;
        if (intersection is LineSegment) {
          return intersection;
        }
        if (intersection.equalTo(lseg.start)) return lseg.start;
        if (intersection.equalTo(lseg.end))   return lseg.end;
        if (enclosesStart) 
          return new LineSegment(lseg.start, intersection);
        if (enclosesEnd)
          return new LineSegment(intersection, lseg.end);
        return intersection;
      case 2: //The segment intersects at two places
        final intersection1 = boundaryIntersections.first;
        final intersection2 = boundaryIntersections.last;
        if (intersection1 is LineSegment) return intersection1;
        if (intersection2 is LineSegment) return intersection2;
        var intersections = boundaryIntersections.toList()
            ..sort((p1, p2) => Comparable.compare(p1.distanceTo(lseg.start), p2.distanceTo(lseg.start)));
        return new LineSegment(intersections[0], intersections[1]);
      default: //Three intersection points, exactly one of them must be a linesegment
        return boundaryIntersections.singleWhere((intersection) => intersection is LineSegment);
    }
  }
  
  /**
   * Returns the area common two the to two [Tessels], allowing for 
   * a maximum innacuracy of the intersection of [:tolerance:]
   * 
   * Returns one of
   * -- A Point, if the two [Tessel]s intersect at one of the vertices of the [Tessels]
   * -- A [LineSegment], if the two [Tessels] intersect along one of the edges
   * -- A [Tessel], if the one of the [Tessel]s contains the other.
   * -- A [Ring], if the two [Tessel]s overlap.
   */  
  Geometry _tesselIntersection(Tessel tesl, {double tolerance: 1e-15}) {
    if (!mbrIntersects(tesl, tolerance: tolerance)) {
      return null;
    }
    Point intersectionPoint;
    List<LineSegment> intersectionSegments = [];
    void addSegment(LineSegment lseg) {
      if (intersectionSegments.isEmpty) {
        intersectionSegments.add(lseg);
      }
      print("Segments: $intersectionSegments");
      print("lseg: $lseg");
      if (intersectionSegments.contains(lseg) || intersectionSegments.contains(lseg.reversed())) {
        return;
      }
      if (intersectionSegments.first.start == lseg.end) {
        intersectionSegments.insert(0, lseg);
        return;
      } else if (intersectionSegments.first.start == lseg.start) {
        intersectionSegments.insert(0, lseg.reversed());
        return;
      }
      //Attempt to insert the segment in a position adjacent to the previous segment 
      for (var i in range(1, intersectionSegments.length)) {
        if (intersectionSegments[i-1].end == lseg.start) {
          intersectionSegments.insert(i, lseg);
          return;
        } else if (intersectionSegments[i - 1].end == lseg.end) {
          intersectionSegments.insert(i, lseg.reversed());
          return;
        }
      }
      //If it is not adjacent to any previous segment, insert it at the end of the list.
      intersectionSegments.add(lseg);
    }
    for (var seg in boundary.segments) {
      var teslIntersection = tesl._segmentIntersection(seg);
      if (teslIntersection is LineSegment) {
        addSegment(teslIntersection);
      }
      if (teslIntersection is Point) {
        intersectionPoint = teslIntersection;
      }
    }
    for (var seg in tesl.boundary.segments) {
      var teslIntersection = _segmentIntersection(seg);
      if (teslIntersection is LineSegment) {
        addSegment(teslIntersection);
      }
      if (teslIntersection is Point) {
        intersectionPoint = teslIntersection;
      }
    }
    print("Finally: $intersectionSegments");
    switch(intersectionSegments.length) {
      case 0:
        //Tessels do not intersect or intersect at a point
        return intersectionPoint;
      case 1:
        //Tessels intersect along an edge
        return intersectionSegments.single;
      default:
        return new Ring.fromSegments(intersectionSegments);
    }
  }
  
  Geometry intersection(Geometry geom, {double tolerance: 1e-15}) {
    if (!mbrIntersects(geom, tolerance: tolerance)) 
      return null;
    if (geom is Point) {
      return encloses(geom, tolerance: tolerance) ? geom : null;
    }
    if (geom is LineSegment) 
      return _segmentIntersection(geom, tolerance: tolerance);
    
    if (geom is Linestring) {
      var intersections = 
          new GeometryList.from(
              (geom as Linestring).segments
              .map((s) => _segmentIntersection(s, tolerance: tolerance))
              .where((isect) => isect != null)
          ).simplify(tolerance: tolerance);
      return (intersections.length == 1) ? intersections.single : intersections;
    }
    
    if (geom is Tessel) {
      return _tesselIntersection(geom, tolerance: tolerance);
    }
    
    return geom.intersection(this, tolerance: tolerance);
  }
  
  _tesselUnion(Tessel tesl, {double tolerance: 1e-15}) {
    if (!mbrIntersects(tesl, tolerance: tolerance)
        || disjoint(tesl, tolerance: tolerance)) {
      return new GeometryList.from([this, tesl], growable: false);
    }
    var unionVerts = boundary.segments
        .fold([], (verts, seg) {
          addIfUniq(Point vert1, [Point vert2]) {
            if (verts.isEmpty || !verts.last.equalTo(vert1, tolerance: tolerance)) {
              verts.add(vert1);
            }
            if (vert2 != null && !verts.last.equalTo(vert2, tolerance: tolerance)) {
              verts.add(vert2);
            }
          }
          if (!tesl._enclosesPoint(seg.start, tolerance: tolerance)) {
            addIfUniq(seg.start);
          }
          for (var teslSeg in tesl.boundary.segments) {
            var intersection = seg._segmentIntersection(teslSeg, tolerance: tolerance);
            if (intersection is LineSegment) {
              addIfUniq(seg.start, seg.end);
            }
            if (intersection is Point) {
              //If the segment and the teslSeg intersect at a point, we have
              //exactly one of the linesegments (teslSeg.start -> intersection)
              //and (intersection -> teslSeg.end) must be part of the union
              if (!_enclosesPoint(teslSeg.end, tolerance: tolerance)) {
                addIfUniq(intersection, teslSeg.end);
              } else {
                addIfUniq(teslSeg.start, intersection);
              }
            }
          }
          if (!tesl._enclosesPoint(seg.end, tolerance: tolerance)) {
            addIfUniq(seg.end);
          }
          return verts;
        });
    return new Ring(unionVerts);
  }
  /**
   * Returns the [:union:] of two [Planar] geometries.
   * The result will be one of:
   * -- A [Tessel], if the [Tessel] encloses [:geom:]
   * -- A [Ring], if the two tessels intersection is nonempty
   * -- A [GeometryList], if the two geometries are disjoint.
   * 
   * NOTE: When intersecting a [Tessel] with a [Polygon], all holes in the polygon
   *       are ignored.
   */
  Geometry union(Planar geom, {double tolerance: 1e-15}) {
    if (disjoint(geom, tolerance: tolerance)) {
      return new GeometryList.from([this, geom]);
    }
    if (geom is Tessel) {
      return _tesselUnion(geom, tolerance: tolerance);
    }
  }
  
  bool intersects(Geometry geom, {double tolerance: 1e-15}) {
    if (!mbrIntersects(geom, tolerance: tolerance)) {
      return false;
    }
    if (geom is Point) return encloses(geom);
    if (geom is LineSegment) {
      var lseg = geom as LineSegment;
      return encloses(lseg.start, tolerance: tolerance)
          || encloses(lseg.end, tolerance: tolerance);
    }
    if (geom is Linestring) {
      var lstr = geom as Linestring;
      return lstr.segments.any((seg) => intersects(seg, tolerance: tolerance));
    }
    if (geom is Tessel) {
      var tes = geom as Tessel;
      return encloses(tes.a, tolerance: tolerance)
          || encloses(tes.b, tolerance: tolerance)
          || encloses(tes.c, tolerance: tolerance);
    }
    return geom.intersects(this, tolerance: tolerance);
  }
  
  bool _enclosesPoint(Point p, {double tolerance: 1e-15}) {
    final cmp_ab = ab.compareToPoint(p, tolerance: tolerance);
    if (cmp_ab == 0) return ab.encloses(p, tolerance: tolerance);
    final cmp_bc = bc.compareToPoint(p, tolerance: tolerance);
    if (cmp_bc == 0) return bc.encloses(p, tolerance: tolerance);
    final cmp_ca = ca.compareToPoint(p, tolerance: tolerance);
    if (cmp_ca == 0) return ca.encloses(p, tolerance: tolerance);
    
    //If the point is on the same side of all the edges, 
    //it is inside the tessel.s
    return cmp_ab > 0 && cmp_bc > 0 && cmp_ca > 0
        || cmp_ab < 0 && cmp_bc < 0 && cmp_ca < 0;
  }
  
  bool encloses(Geometry geom, {double tolerance: 1e-15}) {
    if (geom is Nodal) 
      return _enclosesPoint((geom as Nodal).toPoint(), tolerance: tolerance);
    
    if (geom is Linear) {
      var lstr = (geom as Linear).toLinestring();
      return lstr.every((v) => encloses(v, tolerance: tolerance));
    }
    
    if (geom is Tessel) {
      var tes = geom as Tessel;
      return encloses(tes.a, tolerance: tolerance)
          && encloses(tes.b, tolerance: tolerance)
          && encloses(tes.c, tolerance: tolerance);
    }
    
    if (!mbrIntersects(geom)) return false;
    
    if (geom is GeometryCollection) {
      var components = geom as GeometryCollection;
      return components.every((g) => encloses(g, tolerance: tolerance));
    }
    
    if (geom is Polygon) {
      return encloses((geom as Polygon).outer, tolerance: tolerance);
    }
    
    throw new Exception("Unknown geometry type: ${geom.runtimeType}");
    
  }
  
  /**
   * A [Tessel] is it's own tesselation. Returns a singleton set containing `this`.
   */
  Set<Tessel> tesselate({double tolerance: 1e-15}) => [this].toSet();
  
  /**
   * [Tessel]s cannot be simplified, just returns `this`
   */
  Tessel simplify({double tolerance: 1e-15}) => this;
  
  Polygon toPolygon() => new Polygon(outer: new Ring([a,b,c]));
  
  bool equalTo(Geometry geom, {double tolerance: 1e-15}) {
    if (geom is Tessel) {
      var tes = geom as Tessel;
      //TODO: Should permutations of the vertices compare equal?
      //      Do we ever care about the orientation of a tessel?
      if (tes.a.equalTo(a, tolerance: tolerance)) {
        return tes.b.equalTo(b, tolerance: tolerance)
            && tes.c.equalTo(c, tolerance: tolerance);
      }
      if (tes.a.equalTo(b, tolerance: tolerance)) {
        return tes.b.equalTo(c, tolerance: tolerance)
            && tes.c.equalTo(a, tolerance: tolerance);
      }
      if (tes.a.equalTo(c, tolerance: tolerance)) {
        return tes.b.equalTo(a, tolerance: tolerance)
            && tes.c.equalTo(b, tolerance: tolerance);
      }
      return false;
    }
    //TODO: Should we compare to a Ring with three vertices?
    return false;
  }
  
  bool touches(Geometry geom, {double tolerance: 1e-15}) {
    if (geom is Nodal) {
      return boundary.segments.any((s) => s.encloses(geom, tolerance: tolerance));
    }
    if (geom is LineSegment) {
      final lseg = (geom as LineSegment);
      //If the intersection lies along any edge then it touches the tessel.
      for (var seg in boundary.segments) {
        if (seg.intersection(lseg, tolerance: tolerance) is LineSegment) {
          return true;
        }
      }
      //Otherwise, the segment must either start or end at the boundary
      //but cannot both start and end at the boundary (because then it would need
      //to lie inside the geometry.
      if (boundary.encloses(lseg.start, tolerance: tolerance)) {
        return !boundary.encloses(lseg.end, tolerance: tolerance);
      }
      if (boundary.encloses(lseg.end, tolerance: tolerance)) {
        return !boundary.encloses(lseg.start, tolerance: tolerance);
      }
      return false;
    }
    if (geom is Linestring) {
      final lstr = geom as Linestring;
      bool foundTouch = false;
      for (var seg in lstr.segments) {
        final boundaryIntersection = boundary.intersection(seg, tolerance: tolerance);
        
        if (boundaryIntersection is Point) {
          var isectPoint = boundaryIntersection as Point;
          
          //If the segment intersects at a point, there is a possibility
          //that the linestring touches the polygon at a vertex and then
          //immediately moves in the opposite direction
          if (isectPoint.equalTo(seg.start, tolerance: tolerance)
              || isectPoint.equalTo(seg.end, tolerance: tolerance)) {
            //we can test this by intersecting the tessel with the segment.
            //If it intersects at a single point we are ok.
            var isect = _segmentIntersection(seg, tolerance: tolerance);
            if (isect is! Point) {
              return false;
            }
          } else if(!isectPoint.equalTo(a, tolerance: tolerance)
                    && !isectPoint.equalTo(b, tolerance: tolerance)
                    && !isectPoint.equalTo(c, tolerance: tolerance)) {
            //Otherwise it is only valid if the point is the start or end point of an edge
            //of the tessel.
            return false;        
          }
          foundTouch = true;
        } else if (boundaryIntersection is LineSegment) {
          //The segment lies along an edges
          foundTouch = true;
        }
        //If the intersection is null then we haven't found a point which touches the boundary
      }
      return foundTouch;
    }
    if (geom is Tessel) {
      var tesl = geom as Tessel;
      var isect = _tesselIntersection(tesl, tolerance: tolerance);
      return (isect is Point || isect is LineSegment);
    }
    if (geom is GeometryList) {
      return geom.touches(this, tolerance: tolerance);
    }
  }
  bool operator ==(Object other) {
    if (other is Tessel) {
      //Two tessels compare equal if they can be permuted to match the other tessel.
      var tes = other as Tessel;
      if (tes.a == a) {
        return tes.b == b && tes.c == c;
      }
      if (tes.a == b) {
        return tes.c == a && tes.b == c;
      }
      if (tes.a == c) {
        return tes.b == a && tes.c == b;
      }
      return false;
    }
    return false;
  }
  
  int get hashCode {
    int result = 17;
    result = result * 17 + a.hashCode;
    result = result * 17 + b.hashCode;
    result = result * 17 + c.hashCode;
    return result;
  }
  
  String toString() => "Tessel($a, $b, $c)";
}