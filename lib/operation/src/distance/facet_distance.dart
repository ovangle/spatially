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


part of operation.distance;

Iterable<Linestring> extractLines(Geometry geom, {bool asLinestrings: false}) {
  if (geom is Ring && asLinestrings) {
    return [geom.factory.createLinestring(geom.coordinates)];
  } else if (geom is Linestring) {
    return [geom];
  } else if (geom is GeometryList) {
    return geom.expand(extractLines);
  }
  return [];
}

Iterable<Point> extractPoints(Geometry geom) {
  if (geom is Point) {
    return [geom];
  } else if (geom is GeometryList) {
    return geom.expand(extractPoints);
  }
  return [];
}

Map computeFacetDistance(Geometry g) {}