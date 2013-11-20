library operation.boundary;

import 'dart:collection';

import 'package:spatially/base/coordinate.dart';

import 'package:spatially/algorithm/lb_rule.dart'
  as lb_rule;
import 'package:spatially/geom/base.dart';

Geometry boundaryOf(Geometry g, [lb_rule.VertexInBoundaryRule boundaryRule = lb_rule.OGC_BOUNDARY_RULE]) {
  if (g is Linestring) return _boundaryLinestring(g, boundaryRule);
  if (g is MultiLinestring) return _boundaryMultiLinestring(g, boundaryRule);
  
  //Other boundaries should be implemented directly on the geometry.
  return g.boundary;
}

Geometry _boundaryLinestring(Linestring lstr, lb_rule.VertexInBoundaryRule boundaryRule) {
  if (lstr.isEmptyGeometry)
    return lstr.factory.createEmptyMultiPoint();
  
  if (lstr.isClosed) {
    //Check whether endpoints of valence 2 are in the boundary
    if (boundaryRule(2)) {
      return lstr.startPoint;
    } else {
      return lstr.factory.createEmptyMultiPoint();
    }
  }
  return lstr.factory.createMultiPoint([lstr.startPoint, lstr.endPoint]);
}

Geometry _boundaryMultiLinestring(MultiLinestring multilstr, lb_rule.VertexInBoundaryRule boundaryRule) {
  if (multilstr.isEmptyGeometry)
    return multilstr.factory.createEmptyMultiPoint();
  SplayTreeMap<Coordinate, int> endpointMap = new SplayTreeMap<Coordinate, int>();
  int addEndpoint(Point p) {
    endpointMap.putIfAbsent(p.coordinate, () => 0);
    endpointMap[p.coordinate] += 1;
  }
  
  for (var lstr in multilstr.where((l) => l.length > 0)) {
    addEndpoint(lstr.startPoint);
    addEndpoint(lstr.endPoint);
  }
  
  var boundaryCoords =
      endpointMap.keys
          .where((k) => boundaryRule(endpointMap[k]))
          .map(multilstr.factory.createPoint);
  return multilstr.factory.createMultiPoint(boundaryCoords);
}