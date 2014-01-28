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

class MultiLinestring extends GeometryList<Linestring> {

  MultiLinestring._(List<Linestring> linestrings,
                    GeometryFactory factory) :
      super._(linestrings, factory);

  int get dimension => 1;

  bool get isClosed {
    if (isEmptyGeometry) return false;
    return every((l) => l.isClosed);
  }

  int get boundaryDimension =>
      isNotEmptyGeometry && isClosed ? dim.EMPTY : 0;

  Geometry get boundary => bnd.boundaryOf(this);

  bool equalsExact(Geometry geom, [double tolerance=0.0]) {
    if (geom is! MultiLinestring) return false;
    return super.equalsExact(geom, tolerance);
  }

}