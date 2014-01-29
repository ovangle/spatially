//This file is part of Spatially.
//
//    Spatially is free software: you can redistribute it and/or modify
//    it under the terms of the GNU Lesser General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    Spatially is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU Lesser General Public License for more details.
//
//    You should have received a copy of the GNU Lesser General Public License
//    along with Spatially.  If not, see <http://www.gnu.org/licenses/>.


/**
 * Provides an operation which computes a boolean
 * operation on two geometries.
 * The operation can be one of
 *    [OVERLAY_INTERSECTION]
 *    [OVERLAY_UNION]
 *    [OVERLAY_DIFFERENCE]
 *    [OVERLAY_SYMMETRIC_DIFFERENCE]
 */
library spatially.operation.overlay;

import 'dart:math' as math show max, min;

import 'package:spatially/spatially.dart';
import 'package:spatially/base/linkedlist.dart';
import 'package:spatially/base/tuple.dart';
import 'package:spatially/geom/location.dart' as loc;
import 'package:spatially/geomgraph/geometry_graph.dart';

part 'src/overlay/builders.dart';
part 'src/overlay/in_overlay.dart';
part 'src/overlay/linestring_builder.dart';
part 'src/overlay/point_builder.dart';
part 'src/overlay/polygon_builder.dart';

const int OVERLAY_INTERSECTION = 1;
const int OVERLAY_UNION = 2;
const int OVERLAY_DIFFERENCE = 3;
const int OVERLAY_SYMMETRIC_DIFFERENCE = 4;

Geometry overlayGeometries(Geometry g0, Geometry g1, int overlayType) {
  //Use the factory of the first geometry.
  GeometryFactory geomFactory = g0.factory;

  GeometryGraph geomGraph = new GeometryGraph(g0, g1);
  geomGraph.initialise();

  _OverlayBuilder geomBuilder = new _OverlayBuilder(geomGraph, overlayType);
  return geomBuilder.build();
}
