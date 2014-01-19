library spatially.geomgraph.geometry_graph;

import 'package:collection/equality.dart';
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
  bool _initialised = false;

  GeometryGraph._(Tuple<Geometry,Geometry> this.geometries);

  /**
   * Construct a new [GeometryGraph] from the two specified geometries
   */
  GeometryGraph(Geometry geom1, Geometry geom2) : this._(new Tuple(geom1, geom2));

  /**
   * Initialize the nodes and edges of the [GeometryGraph]
   * from the two geometries
   */
  void initialise() {
    //Add both geometries
    addGeometry(geometries.$1, 1);
    addGeometry(geometries.$2, 2);
    //Node the graph
    nodeGraph();
    labelEdges();
    _initialised = true;
  }

  Node nodeByCoordinate(Coordinate c) =>
      nodes.singleWhere((n) => n.label.coordinate == c);

  /**
   * `true` if both geometries have been added to the graph
   * and the graph has been noded.
   */
  bool get isInitialised => _initialised;

  /**
   * The graph should be noded, complete the labelling of edges.
   */
  void labelEdges() {
    void labelEdge(Edge edge) {
      assert(edge.forwardLabel.isPresent && edge.backwardLabel.isPresent);
      var fwdLabel = edge.forwardLabel.value;
      var bwdLabel = edge.backwardLabel.value;
    }
    edges.forEach(labelEdge);
  }

  /**
   * Finds all intersections in the graph and replaces the intersection points by
   * nodes.
   */
  void nodeGraph() {
    var intersectionInfos = _edgeSetIntersector(new List.from(edges, growable: false));
    for (var edge in new List.from(edges, growable: false)) {
      nodeEdge(edge, intersectionInfos);
    }
  }

  void nodeEdge(Edge edge, Iterable<IntersectionInfo> intersectionInfos) {
    Iterable<List<Coordinate>> splitCoordinates = edge.splitCoordinates(intersectionInfos);
    if (splitCoordinates.length == 1) {
      //No intersections. Don't need to split the edge.
      return;
    }
    //At this stage we should only have undirected edges in the graph.
    assert(edge.forwardLabel.isPresent);
    assert(edge.backwardLabel.isPresent);
    EdgeLabel fwdLabel = edge.forwardLabel.value;
    EdgeLabel bwdLabel = edge.backwardLabel.value;

    Node _addIntersectionNode(Coordinate c) {
      //Find the index of the geometry which we don't know the location of.
      var knownLocationIdx = 0;
      if (fwdLabel.locationDatas.$1.on == loc.NONE) {
        knownLocationIdx = 2;
      }
      if (fwdLabel.locationDatas.$2.on == loc.NONE) {
        //We shouldn't set the `on` location for at least one of the edges
        //before noding.
        assert(knownLocationIdx == 0);
        knownLocationIdx = 1;
      }
      //The on location of at least one of the edges should have been set
      //before noding.
      assert(knownLocationIdx != 0);
      var knownLocation = fwdLabel.locationDatas.project(knownLocationIdx).on;
      return _addCoordinate(knownLocationIdx, c, knownLocation);
    }
    Edge _addSplitEdge(List<Coordinate> coords) {
      assert(coords.length >= 2);
      var startNode = _addIntersectionNode(coords.first);
      var endNode = _addIntersectionNode(coords.last);
      Edge added = this.addUndirectedEdge(
          new EdgeLabel.fromLabel(coords, fwdLabel),
          new EdgeLabel.fromLabel(coords, bwdLabel),
          startNode, endNode);

    }
    //Remove the current edge from the graph
    removeEdge(edge);
    splitCoordinates.forEach((coords) => _addSplitEdge(coords));
  }

  Iterable<graph.GraphNode> get boundaryNodes =>
      (nodes as Iterable<Node>)
      .where((Node n) => n.label.locationDatas.$1.on == loc.BOUNDARY
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

  void addGeometry(Geometry geom, int geometryIdx) {
    if (geom is Point) {
      addPoint(geom, geometryIdx);
    } else if (geom is Linestring) {
      addLinestring(geom, geometryIdx);
    } else if (geom is Polygon) {
      addPolygon(geom, geometryIdx);
    } else {
      addGeometryList(geom, geometryIdx);
    }
  }

  void addPoint(Point p, int geometryIdx) {
    var geom = geometries.project(geometryIdx);
    if (!identical(p, geom) && !(geom is GeometryList && geom.hasComponent(p))) {
      throw new ArgumentError("$p is not the graph geometry at $geometryIdx");
    }
    if (p.isEmptyGeometry) {
      return null;
    }
    _addCoordinate(geometryIdx, p.coordinate, loc.INTERIOR);
  }

  void addLinestring(Linestring lstr, int geometryIdx) {
    var geom = geometries.project(geometryIdx);
    if (!identical(lstr, geom) && !(geom is GeometryList && geom.hasComponent(lstr))) {
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
    if (!identical(poly, geom) && !(geom is GeometryList && geom.hasComponent(poly))) {
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

  void addGeometryList(GeometryList geomList, int geometryIdx) {
    for (var geom in geomList) {
      if (geom is Point) {
        addPoint(geom, geometryIdx);
      } else if (geom is Linestring) {
        addLinestring(geom, geometryIdx);
      } else if (geom is Polygon) {
        addPolygon(geom, geometryIdx);
      } else if (geom is GeometryList) {
        addGeometryList(geom, geometryIdx);
      } else {
        throw new GeometryError("Unknown geometry type: ${geom.runtimeType}");
      }
    }
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