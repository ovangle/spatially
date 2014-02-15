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


library spatially.geomgraph.intersector;

import 'dart:collection' hide LinkedList;
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:quiver/iterables.dart';

import 'package:spatially/spatially.dart';
import 'package:spatially/base/linkedlist.dart';
import 'package:spatially/algorithm/line_intersector.dart' as li;

import 'geometry_graph.dart';

part 'src/intersector/simple_edge_set_intersector.dart';
part 'src/intersector/monotone_chain.dart';
part 'src/intersector/sweep_line.dart';
part 'src/intersector/intersection_info.dart';

// If in debug mode, use the simple intersector.
const bool __DEBUG__ = true;


/**
 * Selects the intersector to use depending on the debug mode.
 * The simple edge set intersector is slow, but easy to follow.
 * The monotone chain intersector is faster in most real world situations,
 * but more difficult to debug.
 */
const EdgeSetIntersector edgeSetIntersector =
    __DEBUG__ ? _simpleEdgeSetIntersector
              : _monotoneChainSweepLineIntersector;

typedef IntersectionSet
        EdgeSetIntersector(List<Edge> edgeLabels,
                          { bool testAll });


const EdgeSetIntersector SIMPLE_EDGE_SET_INTERSECTOR =
    _simpleEdgeSetIntersector;

const EdgeSetIntersector MONOTONE_CHAIN_SWEEP_LINE_INTERSECTOR =
    _monotoneChainSweepLineIntersector;

