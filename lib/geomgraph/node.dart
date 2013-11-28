library geomgraph.node;

import 'dart:collection';

import 'package:spatially/base/coordinate.dart';
import 'package:spatially/geom/location.dart' as loc;
import 'edge.dart';
import 'label.dart';

part 'src/node/node_map.dart';

/**
 * Typedef for methods which create [Node]s
 */
typedef Node NodeFactory(Coordinate coord);

const NodeFactory DEFAULT_NODE_FACTORY = _defaultNodeFactory;
_defaultNodeFactory(c) => new Node(c);

class Node {
  final Coordinate coordinate;
  /**
   * A map of the [DirectedEdge]s which start at this node,
   * ordered in a clockwise fashion around the node, mapped to the endnode
   * of the edge.
   * A [DirectedEdge] is a valid key in the map of terminating edges
   * if the startNode of the edge starts at the coordinate of the node.
   */
  final SplayTreeMap<DirectedEdge,Node> _terminatingEdges;
  Label label;
  
  Node(Coordinate coordinate) :
    this.coordinate = coordinate,
    _terminatingEdges = new SplayTreeMap<DirectedEdge,Node>(
        (DirectedEdge e1, DirectedEdge e2) => e1.compareTo(e2),
        (DirectedEdge e) => e.startNode.coordinate == coordinate);
  
  /**
   * Adds a [DirectedEdge] which terminates at the current node
   */
  void addEdge(DirectedEdge e) {
    _terminatingEdges[e] = e.endNode;
  }
  
  /**
   * Removes the given [DirectedEdge] from the terminating nodes,
   * returning the endNode of the [DirectedEdge]
   */
  Node removeEdge(DirectedEdge e) => _terminatingEdges.remove(e);
  
  void removeAllEdges() => _terminatingEdges.clear();
  
  /**
   * An [Iterable] containing all edges which start at the node,
   * sorted by the direction they leave the node, counter clockwise
   * around the x-axis.
   */
  Iterable<DirectedEdge> get outEdges => _terminatingEdges.keys;
  
  /**
   * An iterable containing all nodes which are connected by
   * an edge to the current node.
   * The resulting nodes are sorted by the edge which connects
   * the node, in a counter clockwise fashion around the x-axis.
   */
  Iterable<Node> get connectedNodes => _terminatingEdges.values;
}