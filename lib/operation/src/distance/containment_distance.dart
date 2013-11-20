part of operation.distance;

Iterable<Polygon> extractPolygons(Geometry geom) {
  if (geom is Polygon) return [geom];
  if (geom is GeometryList) {
    return geom.expand((g) => extractPolygons(g));
  }
  return [];
}

Iterable<_Location> extractInteriorLocations(Geometry geom) {
  if (geom is GeometryList) {
    return geom.expand(
        (g) {
          if (isAtomic(g)) {
              return [new _Location(g, g.coordinate, 0)];
          }
          if (g is GeometryList) {
            return extractInteriorLocations(g);
          }
          return [];
        });   
  }
  return [];
}

bool isAtomic(Geometry g) => g is Point
                          || g is Linestring
                          || g is Polygon;

Map computeContainmentDistance(Geometry g1, Geometry g2, double searchDistance) {
  var containmentDistance12 = containmentDistance(g1, g2, searchDistance);
  if (containmentDistance12 != null 
      && containmentDistance12["min_distance"] <= searchDistance) {
    return containmentDistance12;
  }
  var containmentDistance21 = containmentDistance(g2, g1, searchDistance);
  if (containmentDistance21 != null
      && containmentDistance21["min_distance"] <= searchDistance) {
    return {
      "min_distance" : containmentDistance21["min_distance"],
      "location1" : containmentDistance21["location2"],
      "location2" : containmentDistance21["location1"]
    };
  }
}

Map containmentDistance(Geometry g1, Geometry g2, double searchDistance) {
  Iterable<Polygon> polysIn2 = extractPolygons(g2);
  if (polysIn2.isEmpty) return null;
  Iterable<_Location> locationsIn1 = extractInteriorLocations(g1);
  Map containmentLocation = 
      findContainedLocationInPolys(locationsIn1, polysIn2, searchDistance);
  if (containmentLocation["min_distance"] <= searchDistance) {
    return containmentLocation;
  }
}
Map findContainedLocationInPolys(List<_Location> locations, 
                                 Iterable<Polygon> polys,
                                 double searchDistance) {
  for (var loc in locations) {
    var located = polys.map((p) => coordinateLocationInPoly(loc, p))
                       .firstWhere(
                           (l) => l != null && l["min_distance"] <= searchDistance, 
                           orElse: () => null);
    if (located != null) {
      return located;
    }
  }
}

Map coordinateLocationInPoly(_Location pt, Polygon poly) {
  int loc_index = coord_locator.locateCoordinateIn(pt.coordinate, poly);
  if (loc_index != loc.EXTERIOR) {
    return {
      "min_distance" : 0.0,
      "location1" : pt,
      "location2" : new _Location(poly, pt.coordinate)
    };
  }
  return null;
}
