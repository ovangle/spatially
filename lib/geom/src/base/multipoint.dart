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

class MultiPoint extends GeometryList<Point> {
  MultiPoint._(List<Point> points, GeometryFactory factory)
      : super._(points, factory);

  int get dimension => 0;

  int get boundaryDimension => dim.EMPTY;

  Geometry get boundary =>
    factory.createEmptyGeometryList();

  bool get isValid => true;

  bool equalsExact(MultiPoint g, [double tolerance=0.0]) {
    if (g is! MultiPoint) return false;
    return super.equalsExact(g, tolerance);
  }

  Point operator[](int i) => super[i];
  void operator[]=(int i, Point p) {
    super[i] = p;
  }
}