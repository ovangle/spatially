//This file is part of Spatially.
//
//    Spatially is free software: you can redistribute it and/or modify
//    it under the terms of the GNU Lesser General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    Spatially is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU Lesser General Public License for more details.
//
//    You should have received a copy of the GNU Lesser General Public License
//    along with Spatially.  If not, see <http://www.gnu.org/licenses/>.


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