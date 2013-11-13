library operation.distance;

import 'package:tuple/tuple.dart';

import 'package:spatially/geom/coordinate.dart';
import 'package:spatially/geom/base.dart';
import 'package:spatially/algorithm/point_locator.dart';

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
Tuple2<Coordinate,Coordinate> nearestCoordinates(Geometry g1, Geometry g2,
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

Tuple2 _flipTuple(Tuple2 tup) => new Tuple2(tup.$2, tup.$1);

Tuple2<_Location,_Location> _computeMinimumDistance(
    Tuple2<Geometry,Geometry> geoms, 
    double terminateDistance,
    PointLocator pointLocator,
    Tuple3<_Location,_Location, double> currentApprox) {
  
  //Compute the next approximation from the containment distance
  currentApprox = _computeContainmentDistance(
      geoms,
      terminateDistance,
      pointLocator,
      currentApprox);
  final minDistance = currentApprox.$3;
  if (minDistance <= terminateDistance) {
    //The current approximation is good enoughs
    return currentApprox;
  }
  
}

/**
 * The containment distance is the distance between a point
 * contained in a polygon and 
 */
Tuple3<_Location,_Location, double> _computeContainmentDistance(
    Tuple2<Geometry,Geometry> geoms,
    double terminateDistance,
    PointLocator pointLocator,
    Tuple3<_Location,_Location, double> currentApprox) {
  
}
                          

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