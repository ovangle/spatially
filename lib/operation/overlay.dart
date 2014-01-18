/**
 * Provides an operation which computes a boolean
 * operation on two geometries.
 * The operation can be one of
 *    [OVERLAY_INTERSECTION]
 *    [OVERLAY_UNION]
 *    [OVERLAY_DIFFERENCE]
 *    [OVERLAY_SYMMETRIC_DIFFERENCE]
 */
library operation.overlay;

import 'package:spatially/geom/base.dart';
import 'package:spatially/geomgraph/edge.dart';
import 'package:spatially/geomgraph/label.dart';
import 'package:spatially/geomgraph/node.dart';
import 'package:spatially/geomgraph/geomgraph.dart';
import 'package:spatially/geomgraph/planar_graph.dart';

part 'src/overlay/builders.dart';

const int OVERLAY_INTERSECTION = 1;
const int OVERLAY_UNION = 2;
const int OVERLAY_DIFFERENCE = 3;
const int OVERLAY_SYMMETRIC_DIFFERENCE = 4;

Geometry overlay(Geometry g0, Geometry g1, int overlayType) {
  PlanarGraph result = new PlanarGraph(g0, geom1: g1, nodeFactory: (c) => new Node(c));
  PlanarGraph graphOf0 = graphOf(g0);
  PlanarGraph graphOf1 = graphOf(g1);

  //Perform self-noding
  graphOf0 = graphOf0.intersectSelf();
  graphOf1 = graphOf1.intersectSelf();
  var intersectionGraph = graphOf0.intersectWith(graphOf1);

  _copyNodes(graphOf0, result);
  _copyNodes(graphOf1, result);

  _insertUniqueEdges(graphOf0, result);
  _insertUniqueEdges(graphOf1, result);
  _insertUniqueEdges(intersectionGraph, result);
}

/**
 * Copy all nodes from the [:geomGraph:] into the [:graph:]
 */
void _copyNodes(PlanarGraph geomGraph, PlanarGraph graph) =>
    geomGraph.nodes.forEach(graph.copyNode);

void _insertUniqueEdges(PlanarGraph geomGraph, PlanarGraph graph) {
  for (var edge in geomGraph.edges) {
    Iterable<Edge> equalEdges = graph.edges.where((e) => e == edge);
    if (equalEdges.isNotEmpty) {
      //If an identical edge exists, update its label.
      Edge existingEdge = equalEdges.single;
      Label label = edge.forwardLabel;
      if (existingEdge.forward != edge.forward) {
        label = label.flipped;
      }
      existingEdge.forwardLabel = existingEdge.forwardLabel.mergeWith(label);
    } else {
      graph.copyEdge(edge);
    }
  }
}

