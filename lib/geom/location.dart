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


library geom.location;

/**
 * The location value for the interior of the geometry.
 * Also, the DE-91M row index of the interior of
 * the first geometry and column index of the second
 * geometry.
 */
const int INTERIOR = 0;

/**
 * The location value for the boundary of a geometry.
 * Also, the DE-91M row index of the boundary of the
 * first geometry and column index of the boundary
 * of the second geometry
 */
const int BOUNDARY = 1;

/**
 * The location value for the exterior of the geometry.
 * Also, the DE-91M row index of the exterior of
 * the first geometry and column index of the second
 * geometry.
 */
const int EXTERIOR = 2;

/**
 * Uninitialized location value
 */
const int NONE = -1;

/**
 * Convert the given [:locationValue:] to its
 * symbolic representation.
 */
String toLocationSymbol(int locationValue) {
  switch(locationValue) {
    case EXTERIOR:
      return 'e';
    case BOUNDARY:
      return 'b';
    case INTERIOR:
      return 'i';
    case NONE:
      return '-';
    default:
      throw new ArgumentError("Unrecognised location value: $locationValue");
  }
}


