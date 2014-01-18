library geom_graph.planar_graph;

import 'dart:collection';
import 'package:quiver/core.dart';
import 'package:quiver/iterables.dart';
import 'package:spatially/base/array.dart';
import 'package:spatially/base/coordinate.dart';
import 'package:spatially/base/line_segment.dart';
import 'package:spatially/algorithm/lb_rule.dart' as lb_rule;
import 'package:spatially/algorithm/coordinate_locator.dart';
import 'package:spatially/geom/location.dart' as loc;
import 'package:spatially/geom/base.dart';

import 'node.dart';
import 'edge.dart';
import 'label.dart';
import '../geomgraph2/intersector.dart';

/**
  * A graph which models a given [Geometry]
  */
class PlanarGraph {
  //TODO: Extract interface, move methods which shouldn't
  //      be exposed into an implementation class.
  final NodeFactory nodeFactory;
  final Set<Edge> _edges;
  final Set<DirectedEdge> _dirEdges;
  final SplayTreeMap<Coordinate, Node> _nodeMap;

  /**
   * The primary geometry of the graph.
   */
  final Geometry geom0;
  /**
   * If present, this graph represents an overlay of two geometries
   * All edges and nodes will have a second label.
   */
  final Optional<Geometry> geom1;
  /**
   * Each node which represents a boundary coordinate
   * is counted and matched against the provided
   * boundary rule to determine if it should be counted
   * as a point on the interior or boundary of the
   * geometry.
   */
  final Map<Coordinate, int> _boundaryCounts;
  final lb_rule.VertexInBoundaryRule boundaryRule;

  /**
   * intersector for edges in the geometry.
   * For debugging purposes, this should be SIMPLE_EDGE_SET_INTERSECTOR
   * Later we'll change it to the sweep line intersector
   */
  static const EdgeSetIntersector _edgeIntersector = SIMPLE_EDGE_SET_INTERSECTOR;

  PlanarGraph(Geometry geom0,
              { Geometry geom1,
                lb_rule.VertexInBoundaryRule boundaryRule : lb_rule.OGC_BOUNDARY_RULE,
                NodeFactory this.nodeFactory : DEFAULT_NODE_FACTORY
              })  :
    this.geom0 = geom0,
    this.geom1 = new Optional.fromNullable(geom1),
    _edges = new Set<Edge>(),
    _dirEdges = new Set<DirectedEdge>(),
    _nodeMap = new SplayTreeMap<Coordinate,Node>(),
    _boundaryCounts = new HashMap<Coordinate, int>(),
    this.boundaryRule = boundaryRule;


  Node addNode(Geometry geom,
          Coordinate c,
          {int onLoc: loc.NONE}) {
    Node n = nodeFactory(c);
    if (onLoc == loc.NONE) {
      throw new ArgumentError("No location provided for node");
    }
    if (geom.dimension == 1 && onLoc == loc.BOUNDARY) {
      //dimension one geometries are subject to the
      //provided [boundaryRule].
      //If the boundary rule passes, then the node is
      //considered to be on the boundary, otherwise
      //it is considered to be on the interior
      int count = _boundaryCounts[c];
      count += 1;
      onLoc = boundaryRule(count) ? loc.BOUNDARY : loc.INTERIOR;
      _boundaryCounts[c] = count;
    }
    if (identical(geom,geom0)) {
      n.label0 = new Label(geom0, onLoc);
      n.label1 = geom1.transform((g) => new Label(g, locateCoordinateIn(c, g)));
    } else {
      assert(identical(geom, geom1.value));
      n.label0 = new Label(geom0, locateCoordinateIn(c, geom0));
      n.label1 = geom1.transform((g) => new Label(g, onLoc));
    }
    _nodeMap[c] = n;
    return n;
  }

  /**
   * Adds an edge representing a linear component of [:geom:] to the graph.
   */
  Edge addLinearEdge(Geometry geom,
                Array<Coordinate> coords,
                {int onLoc: loc.NONE}) {
    if (coords.length <= 2) {
      throw new ArgumentError("A linear edge must have at least 2 coordinates");
    }
    if (!_nodeMap.containsKey(coords.first)
        || !_nodeMap.containsKey(coords.last)) {
      throw new ArgumentError("Graph must have nodes representing the first and last coordinates"
                              "of a linear edge");
    }
    LineSegment forwardDirVector =
        new LineSegment(coords[0], coords[1]);
    LineSegment backwardDirVector =
        new LineSegment(coords[coords.length - 2],
                        coords[coords.length - 1]);

    DirectedEdge forward =
        new DirectedEdge(_nodeMap[coords.first],
                         _nodeMap[coords.last],
                         forwardDirVector);

    DirectedEdge backward =
        new DirectedEdge(_nodeMap[coords.last],
                         _nodeMap[coords.first],
                         backwardDirVector);
    _nodeMap[coords.first].addEdge(forward);
    _nodeMap[coords.last].addEdge(backward);

    Edge e = new Edge(this, forward, backward, coords);
    e.coordinates = coords;
    e.forwardLabel0= new Label(geom, onLoc);
    e.forwardLabel1 = new Optional.absent();
    _edges.add(e);
    return e;
  }

  /**
   * Adds an edge representing a planar component of [:geom:] to the graph
   */
  Edge addPlanarEdge(Geometry geom,
                Array<Coordinate> coords,
                {int onLoc: loc.NONE,
                 int leftLoc: loc.NONE,
                 int rightLoc: loc.NONE}) {
    assert(isRing(coords));
    assert(_nodeMap.containsKey(coords.first));

    LineSegment forwardDirVector =
        new LineSegment(coords[0], coords[1]);
    LineSegment backwardDirVector =
        new LineSegment(coords[coords.length - 2],
                        coords[coords.length - 1]);
    DirectedEdge forward =
        new DirectedEdge(_nodeMap[coords.first],
                         _nodeMap[coords.last],
                         forwardDirVector);
    DirectedEdge backward =
        new DirectedEdge(_nodeMap[coords.first],
                         _nodeMap[coords.last],
                         backwardDirVector);
    _nodeMap[coords.first].addEdge(forward);
    _nodeMap[coords.first].addEdge(backward);
    Edge e = new Edge(this, forward, backward, coords);
    e.forwardLabel0 = new Label(geom, onLoc, leftLocation: leftLoc, rightLocation: rightLoc);
    e.forwardLabel1 = new Optional.absent();
    _edges.add(e);
    return e;
  }

  /**
   * Copy a node into the graph.
   */
  void copyNode(Node n, {Label label0, Label label1}) {
    var node = addNode(geom0, n.coordinate);
    if (label0 == null) {
      label0 = new Label(
          geom0,
          locateCoordinateIn(n.coordinate, geom0));
    }
    var optLabel1;
    if (label1 == null) {
      optLabel1 = geom1.transform((g) {
        return new Label(g, locateCoordinateIn(n.coordinate, g));
      });
    }
    node.label0 = label0;
    node.label1 = label1;
  }

  void copyEdge(Edge e, {Label label0, Label label1}) {

  }


  /**
   * Adds an split portion of the given edge to the graph.
   */
  void _addSplitEdge(Edge edge, List<Coordinate> coords) {
    assert(coords.length >= 2);
    assert(_nodeMap.containsKey(coords.first)
           && _nodeMap.containsKey(coords.last));
    var forwardDirVector = new LineSegment(coords[0], coords[1]);
    var backwardDirVector = new LineSegment(coords[coords.length - 1], coords[coords.length - 2]);
    DirectedEdge forward = new DirectedEdge(_nodeMap[coords.first],
                                            _nodeMap[coords.last],
                                            forwardDirVector);
    DirectedEdge backward = new DirectedEdge(_nodeMap[coords.last],
                                             _nodeMap[coords.first],
                                             backwardDirVector);
    Edge e = new Edge(this, forward, backward, coords);
    e.forwardLabel0 = edge.forwardLabel0;
    e.forwardLabel1 = new Optional.absent();
    _edges.add(e);
  }

  /**
   * Retrieve the node with the given coordinate.
   */
  Node getNode(Coordinate c) => _nodeMap[c];
  /**
   * Return an [Iterable] of the nodes in the graph,
   * sorted by the lexicographical ordering of their
   * coordinates.
   */
  Iterable<Node> get nodes => _nodeMap.values;

  /**
   * Return an [Iterable] containing only those nodes
   * in the graph which are on the boundary of the
   * represented geometry.
   */
  Iterable<Node> get boundaryNodes =>
      nodes.where((n) => n.label0 == loc.BOUNDARY);

  /**
   * Return an [Iterable] containing the edges
   * of the graph
   */
  Iterable<Edge> get edges => _edges;

  /**
   * Remove an edge and its associated [DirectedEdge]s
   * from their terminating nodes and from the graph.
   * Does not remove the terminating ndes.
   *
   * Note that there is no way of removing a [DirectedEdge]
   * without removing it's symmetric edge or parent.
   */
  void removeEdge(Edge e) {
    _dirEdges.remove(e.forward);
    _dirEdges.remove(e.backward);
    _edges.remove(e);
    e.remove();
  }

  /**
   * Remove the [Node] from the graph, along with any
   * edges or directed edges which start at the node
   */
  void removeNode(Node node) {
    Iterable<DirectedEdge> outEdges = node.outEdges;
    for (var de in outEdges) {
      removeEdge(de.parentEdge);
    }
    _nodeMap.remove(node.coordinate);
  }

  /**
   * Computes the intersections of all the self intersections
   * on the edges in the graph
   * [:includeProper:] should be `true` if intersections
   * which do not occur on the boundary should be included
   * in the result
   */
  Set<IntersectionInfo> _selfIntersections({bool includeProper: true}) =>
    _edgeIntersector(edges.toList(), testAll: includeProper);

  /**
   * Finds all self intersections in this graph
   * and splits the edges accordingly. A new node is created at
   * every intersection point and the edges in the
   * graph are split so that every node is connected.
   */
  PlanarGraph intersectSelf() {
    assert(!geom1.isPresent);
    Set<IntersectionInfo> selfIntersections = _selfIntersections();
    List<Edge> edgesToRemove = [];
    for (var edge in edges) {
      List<List<Coordinate>> edgeSplitCoords = edge.splitCoordinates(selfIntersections);
      assert(edgeSplitCoords.isNotEmpty);
      if (edgeSplitCoords.length == 1) {
        //No need to split this edge
        continue;
      }
      var numSplitCoords = edgeSplitCoords.length;

      for (var i in range(numSplitCoords)) {
        var splitCoords = edgeSplitCoords[i];
        if (i < numSplitCoords - 1) {
          //Assume that the first coordinate already has a node in the graph, then
          //We only need to add a node for the last coordinate of every split.
          //Don't add the last node again, because this could mess with the boundary counts
          addNode(edge.forwardLabel0.componentOf, splitCoords.last, onLoc: edge.forwardLabel0.onLocation);
        }
        _addSplitEdge(edge, splitCoords);
      }
    }
  }

  PlanarGraph intersectWith(PlanarGraph g) {
    Geometry geom0 = this.geom0;
    Optional<Geometry> geom1 = g.geom1;
  }
}