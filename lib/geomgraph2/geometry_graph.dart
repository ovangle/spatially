library spatially.geomgraph.geometry_graph;

import 'package:quiver/core.dart';
import 'package:spatially/algorithm/cg_algorithms.dart' as cg_algorithms;
import 'package:spatially/base/array.dart';
import 'package:spatially/base/coordinate.dart' show removeRepeatedCoordinates;
import 'package:spatially/base/tuple.dart' show Tuple, zip;
import 'package:spatially/base/coordinate.dart' show Coordinate;
import 'package:spatially/base/line_segment.dart'
        show LineSegment, coordinateSegments;
import 'package:spatially/base/graph.dart' as graph;

import 'package:spatially/algorithm/coordinate_locator.dart'
       show locateCoordinateIn;

import 'package:spatially/geom/base.dart';
import 'package:spatially/geom/location.dart' as loc;

import 'intersector.dart';
import 'location.dart';

part 'src/geometry_graph/edge.dart';
part 'src/geometry_graph/label.dart';
part 'src/geometry_graph/node.dart';

/**
 * Set this to false to enable a much faster edge intersection
 * algorithm.
 */
const bool __DEBUG__ = true;

const EdgeSetIntersector _edgeSetIntersector =
    __DEBUG__
        ? SIMPLE_EDGE_SET_INTERSECTOR
        : MONOTONE_CHAIN_SWEEP_LINE_INTERSECTOR;

class GeometryGraph extends graph.Graph<Coordinate, List<Coordinate>> {
  final Tuple<Geometry,Geometry> geometries;

  GeometryGraph._(Tuple<Geometry,Geometry> this.geometries);

  /**
   * Construct a new [GeometryGraph] from the two specified geometries
   */
  GeometryGraph(Geometry geom1, Geometry geom2) : this._(new Tuple(geom1, geom2));

  /**
   * Initialize the nodes and edges of the [GeometryGraph]
   * from the two geometries
   */
  void initialize() {
    throw new UnimplementedError("Initialize");
  }

  Iterable<Node> get boundaryNodes =>
      nodes.where((n) => n.label.locationDatas.$1.on == loc.BOUNDARY
                      || n.label.locationDatas.$2.on == loc.BOUNDARY);

  Node _addCoordinate(int geometryIdx, Coordinate c, int on) {
    var locDatas =  new Tuple(
          (geometryIdx == 1) ? on : locateCoordinateIn(c, geometries.$1),
          (geometryIdx == 2) ? on : locateCoordinateIn(c, geometries.$2))
    .transform((loc) => new Location(geometries.$1, on: loc),
    (loc) => new Location(geometries.$2, on: loc));
    var nodeLabel = new NodeLabel(c, locDatas);
    return addNode(nodeLabel);
  }

  Edge _addCoordinateList(int geometryIdx, List<Coordinate> coords, Node startNode, Node endNode, int on, {int left, int right}) {
    _location(locIdx) {
      var locs = [on, left, right]
          .map((val) => (val != null && locIdx == geometryIdx) ? val : loc.NONE)
          .toList(growable: false);
      return new Location(geometries.project(locIdx), on: locs[0], left: locs[1], right: locs[2]);
    }
    var locDatas = new Tuple(_location(1), _location(2));
    return addUndirectedEdge(
        new EdgeLabel(coords, locDatas),
        new EdgeLabel(new List.from(coords.reversed, growable: false), locDatas),
        startNode,
        endNode);

  }

  void addPoint(Point p, int geometryIdx) {
    var geom = geometries.project(geometryIdx);
    if (!identical(p, geom) || (geom is GeometryList && !geom.hasComponent(p))) {
      throw new ArgumentError("$p is not the graph geometry at $geometryIdx");
    }
    if (p.isEmptyGeometry) {
      return null;
    }
    _addCoordinate(geometryIdx, p.coordinate, loc.INTERIOR);
  }

  void addLinestring(Linestring lstr, int geometryIdx) {
    var geom = geometries.project(geometryIdx);
    if (!identical(lstr, geom) || (geom is GeometryList && !geom.hasComponent(lstr))) {
      throw new ArgumentError("$lstr is not the graph geometry at $geometryIdx");
    }
    if (lstr.isEmptyGeometry) {
      return;
    }
    //Add nodes corresponding to the start and end points of the linestring.
    var startCoord = lstr.coordinates.first, endCoord = lstr.coordinates.last;
    var startNode = _addCoordinate(geometryIdx, startCoord, loc.BOUNDARY);
    var endNode = _addCoordinate(geometryIdx, endCoord, loc.BOUNDARY);

    //And add the linestring itself
    _addCoordinateList(geometryIdx,
                       new List.from(lstr.coordinates, growable: false),
                       startNode,
                       endNode,
                       loc.INTERIOR);
  }

  /**
   * Add a polygon to the graph.
   * This should be called during [:initialize:]. It is an error if
   * the polygon is not the geometry at [:geometryIdx:]
   */
  void addPolygon(Polygon poly, int geometryIdx) {
    //In order to add the poly we must be either it or a subcomponent of it.
    var geom = geometries.project(geometryIdx);
    if (!identical(poly, geom) || (geom is GeometryList && !geom.hasComponent(poly))) {
      throw new ArgumentError("Not the graph geometry at $geometryIdx");
    }
    if (poly.isEmptyGeometry) {
      return;
    }

    void addRingEdge(Ring r, bool isHole) {
      if (r.isEmptyGeometry)
        return;
      Array<Coordinate> coords = removeRepeatedCoordinates(r.coordinates);
      if (coords.length < 4)
        throw new GeometryError(
            "Too few unique coordinates for polygon ring: $r");
      bool isCounterClockwise = cg_algorithms.isCounterClockwise(coords);
      int locIndexLeft, locIndexRight;
      if (isHole) {
        locIndexLeft = isCounterClockwise ? loc.EXTERIOR : loc.INTERIOR;
        locIndexRight = isCounterClockwise ? loc.INTERIOR : loc.EXTERIOR;
      } else {
        locIndexLeft = isCounterClockwise ? loc.INTERIOR : loc.EXTERIOR;
        locIndexRight = isCounterClockwise ? loc.EXTERIOR : loc.INTERIOR;
      }
      //Add a single node corresponding to the boundary of the ring.
      var startNode = _addCoordinate(geometryIdx, coords.first, loc.BOUNDARY);

      //And add the linestring itself
      _addCoordinateList(
          geometryIdx,
          new List.from(coords, growable: false),
          startNode,
          startNode,
          loc.BOUNDARY,
          left: locIndexLeft,
          right: locIndexRight);
    }
    //Add a ring for the shell of the polygon
    addRingEdge(poly.exteriorRing, false);
    //And a ring for each of the holes
    poly.interiorRings.forEach((h) => addRingEdge(h, true));
  }

  graph.NodeFactory<Coordinate,List<Coordinate>> get nodeFactory => _nodeFactory;
  graph.GraphNode<Coordinate> _nodeFactory(GeometryGraph g,
                                           NodeLabel nodeLabel)
    => new Node(g, nodeLabel);

  graph.EdgeFactory<Coordinate,List<Coordinate>> get edgeFactory => _edgeFactory;
  graph.GraphEdge<List<Coordinate>> _edgeFactory(GeometryGraph g,
                                               Optional<EdgeLabel> fwdLabel,
                                               Optional<EdgeLabel> bwdLabel,
                                               Node startNode,
                                               Node endNode)
      => new Edge(g, fwdLabel, bwdLabel, startNode, endNode);
}