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


part of geom.base;

class MultiPolygon extends GeometryList<Polygon> {
  MultiPolygon._(List<Polygon> polys,
                 GeometryFactory factory) :
    super._(polys, factory);

  int get dimension => 2;

  int get boundaryDimension => 1;

  Geometry get boundary {
    if (isEmptyGeometry) {
      return factory.createEmptyMultiLinestring();
    }
    var allRings = new List<Ring>();
    forEach((poly) {
      allRings.addAll(poly._rings);
    });
    return factory.createMultiLinestring(allRings);
  }

  bool equalsExact(Geometry geom, [double tolerance=0.0]){
    if (geom is! MultiPolygon) return false;
    return super.equalsExact(geom, tolerance);
  }
}