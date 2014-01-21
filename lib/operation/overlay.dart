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
import 'package:spatially/geomgraph/geometry_graph.dart';

part 'src/overlay/builders.dart';

const int OVERLAY_INTERSECTION = 1;
const int OVERLAY_UNION = 2;
const int OVERLAY_DIFFERENCE = 3;
const int OVERLAY_SYMMETRIC_DIFFERENCE = 4;

Geometry overlay(Geometry g0, Geometry g1, int overlayType) {
  GeometryGraph geomGraph = new GeometryGraph(g0, g1);
  geomGraph.initialise();
}
