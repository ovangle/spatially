library geomgraph.geomgraph;

import 'package:spatially/base/array.dart';
import 'package:spatially/base/coordinate.dart';

import 'package:spatially/algorithm/cg_algorithms.dart' as cg_algorithms;
import 'package:spatially/algorithm/lb_rule.dart' as lb_rule;

import 'package:spatially/geom/base.dart';
import 'package:spatially/geom/location.dart' as loc;

import 'planar_graph.dart';

PlanarGraph graphOf(Geometry geom, 
                    [lb_rule.VertexInBoundaryRule boundaryRule = lb_rule.OGC_BOUNDARY_RULE]) {
  if (geom is Point) {
    return graphOfPoint(geom, boundaryRule);
  } else if (geom is Linestring) {
    return graphOfLinestring(geom, boundaryRule);
  } else if (geom is Polygon) {
    return graphOfPolygon(geom, boundaryRule);
  } else if (geom is GeometryList) {
    return graphOfGeometryList(geom, boundaryRule);
  }
  throw new ArgumentError("Unsupported geometry type: $geom");
}

/**
 * The [PlanarGraph] representing a point is a graph
 * with a single node, representing the interior
 * of the point.
 */
PlanarGraph graphOfPoint(Point p, [lb_rule.VertexInBoundaryRule boundaryRule = lb_rule.OGC_BOUNDARY_RULE]) {
  PlanarGraph pointGraph = new PlanarGraph(boundaryRule: boundaryRule);
  _addPointToGraph(pointGraph, p);
  return pointGraph;
}

/**
 * The [PlanarGraph] of a [Linestring] is a graph
 * with a single edge, representing the interior of
 * the linestring and two nodes, representing the two
 * boundary points of the [Linestring]
 */
PlanarGraph graphOfLinestring(Linestring lstr, [lb_rule.VertexInBoundaryRule boundaryRule = lb_rule.OGC_BOUNDARY_RULE]) {
  PlanarGraph lstrGraph = new PlanarGraph(boundaryRule: boundaryRule);
  _addLinestringToGraph(lstrGraph, lstr);
  return lstrGraph;
}

/**
 * Create a new [PlanarGraph] representing the
 * given [Polygon]. The resulting graph contains an edge
 * for each ring in the polygon and a node representing
 * a point on each ring which is on the boundary.
 */
PlanarGraph graphOfPolygon(Polygon poly, [lb_rule.VertexInBoundaryRule boundaryRule = lb_rule.OGC_BOUNDARY_RULE]) {
  PlanarGraph polyGraph = new PlanarGraph(boundaryRule: boundaryRule);
  _addPolygonToGraph(polyGraph, poly);
  return polyGraph;
}

/**
 * Create a new [PlanarGraph] representing the
 * given [MultiPoint]. The resulting graph contains
 * a node for each point in the multipoint and 
 * contains no edges.
 */
PlanarGraph graphOfMultipoint(MultiPoint multipoint, [lb_rule.VertexInBoundaryRule boundaryRule = lb_rule.OGC_BOUNDARY_RULE]) => 
    graphOfGeometryList(multipoint, boundaryRule);

/**
 * Create a new [PlanarGraph] representing the
 * given [MultiLinestring]. For each linestring in the multilinestring,
 * the graph will contain a subgraph isomorphic to the component linestring.
 */

PlanarGraph graphOfMultilinestring(MultiLinestring multilstr, [lb_rule.VertexInBoundaryRule boundaryRule = lb_rule.OGC_BOUNDARY_RULE]) =>
    graphOfGeometryList(multilstr, boundaryRule);

/**
 * Create a new [PlanarGraph] representing the
 * given [MultiPolygon]. For each polygon in the multipolygon,
 * the graph will contain a subgraph isomorphic to the graph of the omponent polygon.
 */
PlanarGraph graphMultipolygon(MultiPolygon multipoly, [lb_rule.VertexInBoundaryRule boundaryRule = lb_rule.OGC_BOUNDARY_RULE]) =>
    graphOfGeometryList(multipoly, boundaryRule);

/**
 * Create a new [PlanarGraph] representing the given [GeometryList]
 * For each component geometry, the graph will contain a subgraph isomorphic
 * to the component geometry.
 */
PlanarGraph graphOfGeometryList(GeometryList geomList, [lb_rule.VertexInBoundaryRule boundaryRule = lb_rule.OGC_BOUNDARY_RULE]) {
  PlanarGraph geomListGraph = new PlanarGraph(boundaryRule: boundaryRule);
  for (var geom in geomList) {
    _addGeometryToGraph(geomListGraph, geom, geomList);
  }
  return geomListGraph;
}

void _addGeometryToGraph(PlanarGraph graph, Geometry geom, [Geometry componentOf=null]) {
  if (geom is Point) {
    _addPointToGraph(graph, geom, componentOf);
  } else if (geom is Linestring) {
    _addLinestringToGraph(graph, geom, componentOf);
  } else if (geom is Polygon) {
    _addPolygonToGraph(graph, geom, componentOf);
  } else if (geom is GeometryList) {
    //Covers MultiPoint, MultiLinestring, MultiPolygon and GeometryList
    for (var g in geom) {
      _addGeometryToGraph(graph, g, componentOf);
    }
  }
}

/**
 * Adds a node representing the interior of the point to the graph.
 * 
 * If [:componentOf:] is provided and non-null, then the geometry is considered
 * to be a component of the argument, and the node will be labelled with the
 * parent geometry.
 */
void _addPointToGraph(PlanarGraph graph, Point p, [Geometry componentOf=null]) {
  if (componentOf == null) componentOf = p;
  graph.addNode(componentOf, p.coordinate, onLoc: loc.INTERIOR);
}

/**
 * Adds an edge representing the interior of the linestring to the graph and two nodes
 * representing the boundary of the linestring.
 * 
 * If [:componentOf:] is provided and non-null, then the geometry is considered
 * to be a component of the argument, and the node will be labelled with the
 * parent geometry.
 */
void _addLinestringToGraph(PlanarGraph lstrGraph, Linestring lstr, [Geometry componentOf=null]) {
  if (componentOf == null) componentOf = lstr;
  Array<Coordinate> linestringCoords =
      removeRepeatedCoordinates(lstr.coordinates);
  if (linestringCoords.length == 1) {
    throw new GeometryError(
        "A linestring must have at least "
        "two distinct coordinates:\n\t$lstr");
  }
  //And add nodes representing the boundaries of the linestring
  lstrGraph.addNode(componentOf, linestringCoords.first, onLoc: loc.BOUNDARY);
  lstrGraph.addNode(componentOf, linestringCoords.last, onLoc: loc.BOUNDARY);
  //Add an edge representing the linestring to the graph
  lstrGraph.addLinearEdge(componentOf, linestringCoords, onLoc: loc.INTERIOR);
}


/**
 * Adds an edge representing the shell of the polygon, and an edge for each of the
 * holes. Also adds a node for each of the rings of the polygon representing the
 * boundary of the polygon.
 * 
 * If [:componentOf:] is provided and non-null, then the geometry is considered
 * to be a component of the argument, and the node will be labelled with the
 * parent geometry.
 */
void _addPolygonToGraph(PlanarGraph graph, Polygon poly, [Geometry componentOf=null]) {
  if (componentOf == null) componentOf = poly;
  /**
   * Add an edge to the graph representing the given ring of the polygon
   */
  addRingEdge(Ring r, bool isHole) {
    if (r.isEmptyGeometry) return;
    Array<Coordinate> ringCoords = removeRepeatedCoordinates(r.coordinates);
    if (ringCoords.length < 4) {
      throw new GeometryError("Too few coordinates in polygon ring: $r");
    }
    bool isCounterClockwise = cg_algorithms.isCounterClockwise(ringCoords);
    int locIndexLeft, locIndexRight;
    if (isHole) {
      locIndexLeft = isCounterClockwise ? loc.EXTERIOR : loc.INTERIOR;
      locIndexRight = isCounterClockwise ? loc.INTERIOR : loc.EXTERIOR;
    } else {
      locIndexLeft = isCounterClockwise ? loc.INTERIOR : loc.EXTERIOR;
      locIndexRight = isCounterClockwise ? loc.EXTERIOR : loc.INTERIOR;
    }
    //And add a node representing the start of the boundary.
    graph.addNode(componentOf, 
                  ringCoords[0], 
                  onLoc: loc.BOUNDARY); 
    //Add the edge representing the ring to the graph
    graph.addPlanarEdge(componentOf, 
                        ringCoords, 
                        onLoc: loc.BOUNDARY, 
                        leftLoc: locIndexLeft, 
                        rightLoc: locIndexRight);
  }
 
  //Add an edge
  addRingEdge(poly.exteriorRing, false);
  for (var hole in poly.interiorRings) {
    addRingEdge(hole, true);
  }
}


