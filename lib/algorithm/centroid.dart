library algorithm.centroid;

import 'package:quiver/iterables.dart';

import 'package:spatially/base/array.dart';

import 'package:spatially/algorithm/cg_algorithms.dart'
    as cg_algorithms;

import 'package:longdouble/longdouble.dart';
import 'package:spatially/base/coordinate.dart';
import 'package:spatially/geom/base.dart';

/**
 * computes the centroid of a Nodal geometry, or
 * computes the centroid of all nodal geometries in a 
 * [GeometryList] or [MultiPoint], ignoring non-nodal geometries.
 */
Coordinate centroidPoint(Geometry geom) {
  Coordinate centroidSum = new Coordinate.origin();
  int pointCount = 0;
  
  void addCoordinate(Coordinate c) {
    centroidSum.x += c.x;
    centroidSum.y += c.y;
    pointCount ++;
  }
  
  //Adds the geometry to the total. Geometries with dimension >= 0 contribute
  //nothing to the total
  void add(Geometry geom) {
    if (geom is Point) {
      addCoordinate(geom.coordinate);
    } else if (geom is GeometryList) {
      geom.forEach(add);
    }
  }
  add(geom);
  if (pointCount == 0) {
    throw new StateError('Could not compute centroid: no points in list');
  }
  return new Coordinate(
      centroidSum.x / pointCount,
      centroidSum.y / pointCount);
  
}

/**
 * Computes the centroid of a [Linestring] or of the lines
 * in a [GeometryList] or [MultiLinestring], ignoring any geometries
 * which are not linear.
 * 
 * Throws a [StateError] if the geometry has zero total length
 */
Coordinate centroidLine(Geometry geom) {
  Coordinate centroidSum = new Coordinate.origin();
  double totalLength = 0.0;
  
  void addCoordinates(Array<Coordinate> coords) {
    double mid(d1, d2) => (d1 + d2) / 2;
    range(1, coords.length).forEach((i) {
      final prev = coords[i - 1];
      final curr = coords[i];
      final segLength = prev.distance(curr);
      
      centroidSum.x += mid(prev.x, curr.x) * segLength;
      centroidSum.y += mid(prev.y, curr.y) * segLength;
      
      totalLength += segLength;
    });
  }
  
  void add(Geometry geom) {
    if (geom is Linestring) {
      addCoordinates(geom.coordinates);
    } else if (geom is Polygon) {
      add(geom.exteriorRing);
      geom.interiorRings.forEach(add);
    } else if (geom is GeometryList) {
      geom.forEach(add); 
    }
  }
  
  add(geom);
  if (totalLength == 0.0) {
    throw new StateError("Lines had no length");
  }
  
  return new Coordinate(
      centroidSum.x / totalLength,
      centroidSum.y / totalLength);
}

/**
 * Computes the centroid of an area geometry, or the centroid
 * of the [Polygon]s in a [MultiPolygon] or [GeometryList] ignoring
 * any components of the latter which have dimension < 3.
 * 
 * Decomposes the geometry into (possibly overlapping) triangles
 * and compute the centroid of the decomposition.
 * 
 * Throws a [StateError] if the argument has zero area.
 */
Coordinate centroidArea(Geometry geom) {
  //The total sum of the areas in geoms
  double areaSum = 0.0;
  longdouble areaSum_ld = new longdouble(0.0);
  //The total centroid. Since we add the centroid a triangle
  //of the polygon at a time, we avoid repeated divisions by
  //keeping 3 * the total in the sum and dividing by 3 at the end
  Coordinate centroidSum = new Coordinate.origin();
  longdouble centroidSum_xld = new longdouble.zero();
  longdouble centroidSum_yld = new longdouble.zero();
  
  //Do we want to use the more expensive longdouble calculation?
  bool use_ld = false;
  
  /**
   * Add the triangle using longdouble arithmetic.
   * Should only be hit if the first time through we obtain a zero areaSum.
   */
  void addTriangle_ld(Coordinate a, Coordinate b, Coordinate c, bool isPositiveArea) {
    var s = isPositiveArea ? 1.0 : -1.0;
    
    var ax = new longdouble(a.x); var ay = new longdouble(a.y);
    var bx = new longdouble(b.x); var by = new longdouble(b.y);
    var cx = new longdouble(c.x); var cy = new longdouble(c.y);
    
    var area_ld = ax * (by - cy)
                + bx * (cy - ay)
                + cx * (ay - by);
    
    centroidSum_xld += area_ld * (ax + bx + cx) * s;
    centroidSum_yld += area_ld * (ay + by + cy) * s;
    
    areaSum_ld += area_ld * s;
  }
  
  void addTriangle(Coordinate a, Coordinate b, Coordinate c, bool isPositiveArea) {
    if (use_ld) {
      addTriangle_ld(a, b, c, isPositiveArea);
      return;
    }
    final s = isPositiveArea ? 1.0 : -1.0;
    
    //This is twice the area of the triangle,
    //but since we add 2* the area to the total
    //and weight the centroid sum by 2* the area,
    //The result will cancel when calculating the centroid
    var area = a.x * (b.y - c.y)
             + b.x * (c.y - a.y)
             + c.x * (a.y - b.y);
    
    //Add 3 times the (weighted) triangle centroid to the _centroidSum
    centroidSum.x += s * area * (a.x + b.x + c.x);
    centroidSum.y += s * area * (a.y + b.y + c.y);
   
    areaSum += s * area;   
  }
  
 
  
  void addAllTriangles(Coordinate triangleBase, Array<Coordinate> ring, bool isPositiveArea) {
    range(1, ring.length)
        .forEach((i) => addTriangle(triangleBase, ring[i-1], ring[i], isPositiveArea));
  }
  //A shell contributes a positive area if its coordinates are clockwise
  bool shellPositiveArea(Array<Coordinate> coords) => 
      !cg_algorithms.isCounterClockwise(coords); 
  //A hole contributes a positive area if its coordinates are counter-clockwise
  bool holePositiveArea(Array<Coordinate> coords) => 
      cg_algorithms.isCounterClockwise(coords);
  
  //Adds the shell
  void addShell(Array<Coordinate> shell) =>
      addAllTriangles(shell.first, shell, shellPositiveArea(shell));
  
  //Add all the triangles formed by connecting the hole with the start of the shell
  void addHole(Array<Coordinate> shell, Array<Coordinate> hole) =>
      addAllTriangles(shell.first, hole, holePositiveArea(hole));
  
  //Add the polygon to the centroid
  void addPolygon(Polygon poly) {
    var shell = poly.exteriorRing.coordinates;
    addShell(shell);
    poly.interiorRings.forEach((h) => addHole(shell, h.coordinates));
  }
  
  void addGeometryList(GeometryList geomList) {
    for (var g in geomList) {
      if (g is Polygon) addPolygon(g);
      if (g is GeometryList) addGeometryList(g);
    }
  }
  
  if (geom is Polygon) addPolygon(geom);
  if (geom is GeometryList) addGeometryList(geom);
 
  if (areaSum == 0.0) {
    use_ld = true;
    if (geom is Polygon) addPolygon(geom);
    if (geom is GeometryList) addGeometryList(geom);
    if (areaSum_ld.toDouble() == 0.0) {
      throw new StateError("Cannot calculate area-weighted centroid for polygon with area 0.0");
    }
    return new Coordinate(
        (centroidSum_xld / (areaSum_ld * 3)).toDouble(),
        (centroidSum_yld / (areaSum_ld * 3)).toDouble());
  }
  
  return new Coordinate(
      (centroidSum.x / 3) / areaSum,
      (centroidSum.y / 3) / areaSum);
  
}
