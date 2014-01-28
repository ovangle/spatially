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


library operation.distance;

import 'package:spatially/base/coordinate.dart';
import 'package:spatially/geom/base.dart';
import 'package:spatially/geom/location.dart' as loc;
import 'package:spatially/algorithm/coordinate_locator.dart'
    as coord_locator;


part 'src/distance/location.dart';
part 'src/distance/containment_distance.dart';
part 'src/distance/facet_distance.dart';
double distance(Geometry g1, Geometry g2, [double terminateDistance=0.0]) {
  throw 'distance.distance not implemented';
}

/**
 * Find the coordinates of the nearest points in the two geometries.
 * The first item of the tuple is a point in [:g1:] nearest to [:g2:]
 * The second item of the tuple is a point in of [:g2:] closest to [:g1:]
 *
 * [:terminateDistance:] is a distance that is "good enough" to be used
 * as the distance between the two geometries. The search for nearest points
 * will halt once points seperated by [:terminateDistance:] are found within
 * the respective geometries.
 *
 * Throws a [StateError] if either of the geometries are empty.
 */
Map<String,Coordinate> nearestCoordinates(Geometry g1, Geometry g2, [double terminateDistance=0.0]) {
  throw 'distance.nearestCoordinates not implemented';
}

