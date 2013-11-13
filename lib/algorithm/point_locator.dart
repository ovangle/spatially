library algorithm.point_locator;

import 'package:tuple/tuple.dart';
import 'package:spatially/geom/base.dart';
import 'package:spatially/geom/coordinate.dart';
import 'package:spatially/geom/location.dart' as loc;
import 'lb_rule.dart' as bn_rule;


/**
 * Computes the topological [Location] of a single point to a [Geometry].
 * A [VertexInBoundaryRule] may be specified to control evaluation of whether
 * the point lies on the boundary or not.
 * 
 * The default rule is the *SFS Boundary Determination Rule
 * 
 * NOTE:
 * -- [LinearRing]s do not enclose any area -- points inside the
 * ring are still int the EXTERIOR of the ring.
 */
class PointLocator {
  
  bn_rule.VertexInBoundaryRule _boundaryRule;
     
  PointLocator([bn_rule.VertexInBoundaryRule boundaryRule]) {
    if (boundaryRule != null) {
      this._boundaryRule = boundaryRule;
    } else {
      //default to the SFS Boundary Determination Rule
      this._boundaryRule = bn_rule.MOD2_BOUNDARY_RULE;
    }
  }
  
  /**
   * Convenience methd for testing intersection with a 
   * geometry
   */
  bool intersects(Coordinate c, Geometry geom) =>
    locate(c, geom) != loc.EXTERIOR;
  
  /**
   * Returns the location value for the [Coordinate] in
   * the given [Geometry]
   */
  int locate(Coordinate c, Geometry geom) {
    if (geom.isEmptyGeometry) return loc.EXTERIOR;
  }
  
  /**
   * Update the [:locationInfo:] for the 
   */
  Map _updateLocationInfo(Map locationInfo, 
                          int locValue) {
    if (locValue == loc.INTERIOR) {
      locationInfo["isIn"] = true;
    }
    if (locValue == loc.BOUNDARY) {
      locationInfo["numBoundaries"] = locationInfo["numBoundaries"] + 1;
    }
    return locationInfo;
  }
  
  Map _computeLocation(Coordinate c, Geometry geom) {
    //True if c is contained by any of the component geometries
    bool isIn = false;
    //The number of sub-elements whose boundaries the coordinate
    //lies in
    int numBoundaries = 0;
    _updateLocationInfo(int locationValue) {
      if (locationValue == loc.INTERIOR) {
        isIn = true;
      }
      if (locationValue == loc.BOUNDARY) {
        numBoundaries += 1;
      }
    }
    if (geom is Point) 
      return _updateLocationInfo(_locateInPoint(c, geom));
    //TODO: More geometries. 
  }
  
  _locateInPoint(Coordinate c, Point pt) {
    if (pt.coordinate.equals2d(c)) {
      return loc.INTERIOR;
    }
    return loc.EXTERIOR;
  }
}