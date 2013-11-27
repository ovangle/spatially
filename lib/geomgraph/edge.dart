library geomgraph.edge;

import 'dart:collection';
import 'dart:math' as math;

import 'package:spatially/base/array.dart';
import 'package:spatially/base/coordinate.dart';

import 'package:spatially/algorithm/cg_algorithms.dart'
    as cg_algorithms;

import 'node.dart';
import 'label.dart';

part 'src/edge/directed_edge.dart';

class Edge {
  DirectedEdge _forward;
  DirectedEdge _backward;
  
  Label label;
  
  UnmodifiableListView<Coordinate> _coordinates;
  
  Edge(DirectedEdge forward, 
       DirectedEdge backward,
       Array<Coordinate> _coordinates) {
    this.forward = forward;
    this.backward = backward;
    this._coordinates = new UnmodifiableListView(_coordinates);
  }
  
  UnmodifiableListView<Coordinate> get coordinates =>
     _coordinates;
  void set coordinates(Iterable<Coordinate> coords) {
    this._coordinates = new UnmodifiableListView(coords);
  }
  
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
  }
}