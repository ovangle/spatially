part of geometry_tests;

Matcher disjoint(Geometry geom) => isNot(intersects(geom));
Matcher intersects(Geometry geom) => new _Intersects(geom);

class _Intersects extends Matcher {
  Geometry _geom;
  
  _Intersects(Geometry this._geom);
  bool matches(item, Map matchState) {
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
    default:
      throw 'NotImplemented';
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