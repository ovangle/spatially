library operation.distance;

import '../base/coordinate.dart';
import 'package:spatially/geom/base.dart';
import 'package:spatially/geom/location.dart' as loc;
import 'package:spatially/algorithm/coordinate_locator.dart'
    as coord_locator;


part 'src/distance/location.dart';
part 'src/distance/containment_distance.dart';
part 'src/distance/facet_distance.dart';
double distance(Geometry g1, Geometry g2, [double terminateDistance=0.0]) {
  Tuple2 minDistanceLocations = 
      _computeMinimumDistance(
          new Tuple2(g1, g2),
          terminateDistance, 
          new PointLocator(), 
          new Tuple3(null, null, double.INFINITY));
  return minDistanceLocations.$1.coordinate
      .distanceTo(minDistanceLocations.$2.coordinate);
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
Map<String,Coordinate> nearestCoordinates(Geometry g1, Geometry g2,
                                                 [double terminateDistance=0.0]) {
  if (g1.isEmptyGeometry || g2.isEmptyGeometry) {
    throw new StateError("Empty geometry has no nearest coordinate");
  }
  Tuple2 minDistanceLocations = 
      _computeMinimumDistance(
          new Tuple2(g1, g2),
          terminateDistance, 
          new PointLocator(), 
          new Tuple3(null, null, double.INFINITY));
 return new Tuple2(minDistanceLocations.$1.coordinate, 
                   minDistanceLocations.$2.coordinate);
}

