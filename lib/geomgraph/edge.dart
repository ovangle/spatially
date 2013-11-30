library geomgraph.edge;

import 'dart:collection';

import 'package:quiver/iterables.dart';

import 'package:spatially/base/array.dart';
import 'package:spatially/base/coordinate.dart';
import 'package:spatially/base/line_segment.dart';

import 'package:spatially/algorithm/cg_algorithms.dart'
    as cg_algorithms;
import 'package:spatially/geom/base.dart';

import 'node.dart';
import 'label.dart';
import 'intersector.dart';
import 'planar_graph.dart';

part 'src/edge/directed_edge.dart';
part 'src/edge/edge_intersection.dart';

class Edge {
  PlanarGraph parentGraph;
  DirectedEdge _forward;
  DirectedEdge _backward;
  
  Label label;
  
  EdgeIntersections _edgeIntersections;
  UnmodifiableListView<Coordinate> _coordinates;
  
  Edge(PlanarGraph parentGraph,
       DirectedEdge forward, 
       DirectedEdge backward,
       Array<Coordinate> coordinates) :
    this.parentGraph = parentGraph,
    this._forward = forward,
    this._backward = backward,
    this._coordinates = new UnmodifiableListView(coordinates) {
    _edgeIntersections = new EdgeIntersections(this);
  }

  
  UnmodifiableListView<Coordinate> get coordinates =>
     _coordinates;
  void set coordinates(Iterable<Coordinate> coords) {
    this._coordinates = new UnmodifiableListView(coords);
  }
  
  Iterable<LineSegment> get segments =>
      range(1, _coordinates.length - 1)
      .map((i) => new LineSegment(_coordinates[i-1], _coordinates[i]));
  
  DirectedEdge get forward => _forward;
  void set forward(DirectedEdge de) {
    _forward = de;
    de._parentEdge = this;
    de._isForward = true;
  }
  
  DirectedEdge get backward => _backward;
  void set backward(DirectedEdge de) {
    _backward = de;
    de._parentEdge = this;
    de._isForward = false;
  }
  
  void setDirectedEdges(DirectedEdge forward, DirectedEdge backward) {
    this.forward = forward;
    this.backward = backward;
  }
  
  /**
   * Returns the edge with the given startNode.
   * Returns `null` if neither edge starts at the given node.s
   */
  DirectedEdge getFromStartNode(Node startNode) {
    if (forward.startNode == startNode) return forward;
    if (backward.startNode == startNode) return backward;
    return null;
  }
  
  /**
   * If the given node is the start node of one of the
   * edges, returns the other edge.
   * Returns `null` if neither edge starts at the given node.
   */
  DirectedEdge getOppositeNode(Node startNode) {
    var edge = getFromStartNode(startNode);
    if (edge == null) return null;
    return edge.isForward ? backward : forward;
  }
  
  /**
   * Removes this and any children from the graph 
   */
  bool remove() {
    if (_forward != null) {
      _forward._parentEdge = null;
      _forward = null;
    }
    if (_backward != null) {
      _backward._parentEdge = null;
      _backward = null;
    }
    parentGraph = null;
  }
  
  void addIntersections(List<IntersectionInfo> intersections) {
    intersections.forEach(addIntersection);
  }
  
  void addIntersection(IntersectionInfo intersection) {
    var isectCoord;
    if (intersection is Coordinate) {
      isectCoord = intersection;
    } else if (intersection is LineSegment) {
      isectCoord = intersection.start;
    } else {
      throw new ArgumentError("Intersection must be a Coordinate or LineSegment");
    }
    int segmentIndex = 
        coordinates.firstWhere((c) => isectCoord);
    _edgeIntersections.add(intersection, segmentIndex, dist);
  }
} 