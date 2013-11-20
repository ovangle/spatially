library geom.utils;

import 'base.dart';

/**
 * Returns an [Iterable] of all [Point] components of
 * [:geom:]
 * 
 * -- If [:geom:] is a [Point], returns a [Iterable] containing geom
 * -- If [:geom:] is a [GeometryList] recursively collects all [Points]
 *    in [:geom:] and in any sublists of [:geom:]
 * Otherwise, returns an empty [Iterable].
 */
Iterable<Point> extractPoints(Geometry geom) {
  if (geom is Point) 
    return [geom];
  if (geom is GeometryList) 
    return geom.expand(extractPoints);
  return [];
}

/**
 * Collects any linear geometries in [:geom:]
 * 
 * -- If [:geom:] is a [Linestring] or [Ring] returns an [Iterable]
 *    containing [:geom:]
 * -- If [:geom:] is a [GeometryList], recursively collects all linear
 *    components of [:geom:]
 *    
 * If [:asLinestrings:] is `true`, then all [Ring] geometries will
 * be converted to [Linestring]s in the resulting iterable.
 * 
 * NOTE: [Ring]s inside [Polygon]s are not collected by this method.
 */
Iterable<Linestring> extractLines(Geometry geom, {bool asLinestrings: false}) {
  if (geom is Ring && asLinestrings)
    return [geom.factory.createLinestring(geom.coordinates)];
  if (geom is Linestring) 
    return [geom];
  if (geom is GeometryList) 
    return geom.expand((g) => extractLines(g, asLinestrings: asLinestrings));
  return [];
}

/**
 * Collects any polygonal geometries in [:geom:]
 * 
 * -- If [:geom:] is a [Polygon] returns an [Iterable] containing [:geom:]
 * -- If [:geom:] is a [GeometryList], recursively collects all [Polygon]
 *    components of [:geom:] and its sublists.
 */
Iterable<Polygon> extractPolygons(Geometry geom) {
  if (geom is Polygon)
    return [geom];
  if (geom is GeometryList)
    return geom.expand(extractPolygons);
  return [];
}