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



class _Location {
  /**
  * A special value of [:segmentIndex:] used for locations inside
  * area geometries. These locations are not located on a segment, thus
  * do not have a [:segmentIndex:]
  */
  static const int INSIDE_AREA = -1;

  final Geometry component;
  final int segmentIndex;
  final Coordinate coordinate;

  /**
  * Create a [GeometryLocation] specifing a point in a geometry
  * If segmentIndex is not provided, assumed to be a point inside the
  * area of a geometry.
  */
  _Location(Geometry this.component, Coordinate this.coordinate,
  [int this.segmentIndex=INSIDE_AREA]);

  /**
  * Test whether this location is a point inside an area geometry
  */
  bool get isInsideArea => segmentIndex == INSIDE_AREA;
}