library geom_graph.planar_graph;

import 'dart:collection';
import 'package:spatially/base/array.dart';
import 'package:spatially/base/coordinate.dart';
import 'package:spatially/base/line_segment.dart';
import 'package:spatially/algorithm/lb_rule.dart' as lb_rule;
import 'package:spatially/geom/location.dart' as loc;
import 'package:spatially/geom/base.dart';

import 'node.dart';
import 'edge.dart';
import 'label.dart';

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
  final lb_rule.VertexInBoundaryRule boundaryRule;
  
  PlanarGraph({ lb_rule.VertexInBoundaryRule boundaryRule : lb_rule.OGC_BOUNDARY_RULE,
                NodeFactory this.nodeFactory : DEFAULT_NODE_FACTORY
              })  :
    _edges = new Set<Edge>(),
    _dirEdges = new Set<DirectedEdge>(),
    _nodeMap = new SplayTreeMap<Coordinate,Node>(),
    this.boundaryRule = boundaryRule;
  
  addNode(Geometry geom, 
          Coordinate c, 
          {int onLoc: loc.NONE}) {
    Node n = nodeFactory(c);
    n.label = new Label.nodeLabel(geom, onLoc);
  }
  
  void addLinearEdge(Geometry geom, 
                Array<Coordinate> coords, 
                {int onLoc: loc.NONE}) {
    assert(coords.length >= 2);
    assert(_nodeMap.containsKey(coords.first));
    assert(_nodeMap.containsKey(coords.last));
    
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
    e.label = new Label.linearLabel(geom, onLoc);
    _edges.add(e);
  }
  
  addPlanarEdge(Geometry geom, 
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
    e.label = new Label.planarLabel(geom, onLoc: onLoc, leftLoc: leftLoc, rightLoc: rightLoc);
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
      nodes.where((n) => n.label == loc.BOUNDARY);
  
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
}