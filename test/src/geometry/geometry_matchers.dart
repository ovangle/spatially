part of geometry_tests;

Matcher disjoint(Geometry geom) => isNot(intersects(geom));
Matcher intersects(Geometry geom) => new _Intersects(geom);

class _Intersects extends Matcher {
  Geometry _geom;
  
  _Intersects(Geometry this._geom);
  
  bool matches(item, Map matchState) {
    if (item == null) {
      return false;
    }
    return item.intersects(_geom);  
  }
  
  Description describe(Description description) {
    return description
        .add(' intersects ')
        .addDescriptionOf(_geom);
  }
}


Matcher encloses(Geometry geom) => new _Encloses(geom);

class _Encloses extends Matcher {
  Geometry _geom;
  
  _Encloses(Geometry this._geom);
  bool matches(item, Map matchState) {
    return item.encloses(_geom);  
  }
  
  Description describe(Description description) {
    return description
        .add(' encloses ')
        .addDescriptionOf(_geom);
  }
}

Matcher enclosedBy(Geometry geom) => new _EnclosedBy(geom);

class _EnclosedBy extends Matcher {
  Geometry _geom;
  
  _EnclosedBy(Geometry this._geom);
  bool matches(item, Map matchState) {
    return item.enclosedBy(_geom);  
  }
  
  Description describe(Description description) {
    return description
        .add(' enclosed by ')
        .addDescriptionOf(_geom);
  }
}

Matcher touches(Geometry geom) => new _Touches(geom);

class _Touches extends Matcher {
  Geometry _geom;
  
  _Touches(Geometry this._geom);
  bool matches(item, Map matchState) {
    return item.encloses(_geom);  
  }
  
  Description describe(Description description) {
    return description
        .add(' touches ')
        .addDescriptionOf(_geom);
  }
}

Matcher boundsCloseTo(Bounds b, double delta) {
  return allOf(boundsTop(closeTo(b.top, delta)),
               boundsBottom(closeTo(b.bottom, delta)),
               boundsLeft(closeTo(b.left, delta)),
               boundsRight(closeTo(b.right, delta)));
}

Matcher boundsTop(Matcher matcher) => new _BoundsMatcher("top", (b) => b.top, matcher);
Matcher boundsBottom(Matcher matcher) => new _BoundsMatcher("bottom", (b) => b.bottom, matcher);
Matcher boundsLeft(Matcher matcher) => new _BoundsMatcher("left", (b) => b.left, matcher);
Matcher boundsRight(Matcher matcher) => new _BoundsMatcher("right", (b) => b.right, matcher);

class _BoundsMatcher extends CustomMatcher {
  final _getFeature;
  
  _BoundsMatcher(String dir, double this._getFeature(actual), Matcher matcher) :
    super("Bounds $dir value is ", "$dir", matcher);
  featureValueOf(actual) => _getFeature(actual);
}

Matcher geometryCloseTo(Geometry geom, double delta) {
  switch(geom.runtimeType) {
    case Point: 
      return pointCloseTo(geom, delta);
    case LineSegment:
      return linearCloseTo((geom as Linear).toLinestring(), delta);
    case Linestring:
      return linearCloseTo(geom, delta);
    default:
      throw 'geometryCloseTo not implemented for ${geom.runtimeType}';
  }
}

Matcher linearCloseTo(Linestring lstr, double delta) =>
    new _LinestringCloseTo(lstr, delta);

class _LinestringCloseTo extends Matcher {
  Linestring _lstr;
  double _delta;
  _LinestringCloseTo(Linestring this._lstr, double this._delta);
  bool matches(item, Map matchState) {
    if (item is! Linear) {
      return false;
    }
    item = item.toLinestring();
    if (item.length != _lstr.length) {
      return false;
    }
    for (int i=0;i<item.length;i++) {
      if (utils.compareDoubles(item[i].x, _lstr[i].x, _delta) != 0) {
        addStateInfo(matchState, {'vertex_x' : i});
        return false;
      }
      if (utils.compareDoubles(item[i].y, _lstr[i].y, _delta) != 0) {
        addStateInfo(matchState, {'vertex_y' : i});
        return false;
      }
    }
    return true;
  }
  
  Description describe(Description description) {
    description.add('Linestring equal to ')
               .addDescriptionOf(_lstr)
               .add('up to a tolerance of ')
               .addDescriptionOf(_delta);
  }
  
  Description describeMismatch(item, Description mismatchDescription,
                               Map matchState, bool verbose) {
    if (item is! Linestring) {
      mismatchDescription.add(' not a Linestring');
      return mismatchDescription;
    }
    if (item.length != _lstr.length) {
      mismatchDescription
          .add(' length was ${item.length}, which differs by ${(item.length - _lstr.length).abs()}');
      return mismatchDescription;
    }
    var failVertex = matchState['vertex_x'];
    if (failVertex != null) {
      mismatchDescription
          .add('which differed at vertex ${failVertex} in the x coordinate')
          .add(' by ${(item[failVertex].x - _lstr[failVertex].x).abs()}');
    } else {
      failVertex = matchState['vertex_y'];
      mismatchDescription
          .add('which differed at vertex ${failVertex} in the y coordinate')
          .add(' by ${(item[failVertex].y - _lstr[failVertex].y).abs()}');
    }
    return mismatchDescription;
  }
}


Matcher pointCloseTo(Point p, double delta) {
  return allOf(
      new _PointMatcherX(closeTo(p.x, delta)),
      new _PointMatcherY(closeTo(p.y, delta))
  );
}

class _PointMatcherX extends CustomMatcher {
  _PointMatcherX(matcher) :
    super("Point x value that is ", "x", matcher);
  featureValueOf(actual) => actual.x;
}

class _PointMatcherY extends CustomMatcher {
  _PointMatcherY(matcher) :
    super("Point y value that is", "y", matcher);
  featureValueOf(actual) => actual.y;
}