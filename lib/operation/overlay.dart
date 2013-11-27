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

import 'package:spatially/base/coordinate.dart';
import 'package:spatially/geom/base.dart';
import 'package:spatially/geomgraph/node.dart';
import 'package:spatially/geomgraph/geomgraph.dart';
import 'package:spatially/geomgraph/planar_graph.dart';

const int OVERLAY_INTERSECTION = 1;
const int OVERLAY_UNION = 2;
const int OVERLAY_DIFFERENCE = 3;
const int OVERLAY_SYMMETRIC_DIFFERENCE = 4;

const NodeFactory OVERLAY_NODE_FACTORY = _overlayNodeFactory;

Geometry overlay(Geometry g0, Geometry g1, int overlayType) {
  PlanarGraph graph = new PlanarGraph(nodeFactory: OVERLAY_NODE_FACTORY);
  PlanarGraph graphOf0 = graphOf(g0);
  PlanarGraph graphOf1 = graphOf(g1);
  
}

Node _overlayNodeFactory(Coordinate c) {
  return new Node(c);
}