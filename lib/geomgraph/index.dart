library geomgraph.index;

import 'dart:collection';

import 'package:quiver/core.dart';
import 'package:quiver/iterables.dart';

import 'package:spatially/base/coordinate.dart';
import 'package:spatially/base/line_segment.dart';
import 'package:spatially/base/envelope.dart';
import 'package:spatially/algorithm/cg_algorithms.dart';
import 'package:spatially/algorithm/line_intersector.dart' as li;

import 'edge.dart';
import 'node.dart';

part 'src/index/simple_edge_set_intersector.dart';
part 'src/index/monotone_chain.dart';
part 'src/index/sweep_line.dart';

typedef List<IntersectionInfo> 
        EdgeSetIntersector(List<Edge> edges,
                          { bool testAll,
                            bool includeProper });

/**
 * A slow intersector which simply compares each
 * of the edges in the edge set pairwise.
 * Useful for debugging.
 */
const EdgeSetIntersector SIMPLE_EDGE_SET_INTERSECTOR = 
    _simpleEdgeSetIntersector;

const EdgeSetIntersector MONOTONE_CHAIN_SWEEP_LINE_INTERSECTOR = 
    _monotoneChainSweepLineIntersector;

class IntersectionInfo {
  /**
   * The first edge of the intersection info 
   * and the index of the segment at which the intersection
   * was recorded.
   */
  final Edge edge0; final int segIndex0; final double edgeDistance0;
  /**
   * The second edge of the intersection info
   * and the index of the segment at which the intersection
   * was recorded
   */
  final Edge edge1; final int segIndex1; final double edgeDistance1;
  /**
   * The coordinate or linesegment of intersection
   */
  final /*Coordinate | LineSegment */ intersection;
  /**
   * An intersection is proper if it touches neither of
   * the endpoints of the intersecting segments
   */
  final bool isProper;
  /**
   * An intersection is proper and in the interior of
   * the segment if the 
   */
  final bool isProperInterior;
  
  IntersectionInfo._(Edge this.edge0, int this.segIndex0, double this.edgeDistance0,
                     Edge this.edge1, int this.segIndex1, double this.edgeDistance1,
                     this.intersection,
                     bool this.isProper,
                     bool this.isProperInterior);
 
  
  bool get isSelfIntersection => edge0 == edge1;
  
  bool operator ==(Object other) {
    if (other is IntersectionInfo) {
      return edge0 == other.edge0 && segIndex0 == other.segIndex0
          && edge1 == other.edge1 && segIndex1 == other.segIndex1;
    }
    return false;
  }
  int get hashCode {
    int hashCode = 19;
    hashCode += hashCode * 19 + edge0.hashCode;
    hashCode += hashCode * 19 + segIndex0.hashCode;
    hashCode += hashCode * 19 + edge1.hashCode;
    hashCode += hashCode * 19 + segIndex1.hashCode;
    return hashCode;
  }
}


Optional<IntersectionInfo> _getIntersectionInfo(Edge edge0, int segIndex0, 
                                                Edge edge1, int segIndex1) {
  //We're not intersested in the intersection of a segment with itself.
  if (edge0 == edge1 && segIndex0 == segIndex1) return new Optional.absent();
  
  LineSegment lseg0 = edge0.segments.elementAt(segIndex0);
  LineSegment lseg1 = edge0.segments.elementAt(segIndex1);
  
  final intersection = li.segmentIntersection(lseg0, lseg1);
  if (intersection == null) return new Optional.absent();
  
  var isProper = false;
  var isProperInterior = false;
  var edgeDistance0, edgeDistance1;
  
  if (intersection is Coordinate) {
    //Check if the intersection is just an adjacency of two segments
    if (edge0 == edge1) {
      if ((segIndex0 - segIndex1).abs() == 1) {
        return new Optional.absent();
      }
      if (edge0.coordinates.first == edge0.coordinates.last
          && (segIndex0 - segIndex1).abs() == edge0.coordinates.length - 1) {
        return new Optional.absent();
      }
      isProper = intersection != lseg0.start
              && intersection != lseg0.end
              && intersection != lseg1.start
              && intersection != lseg1.end;
      
      //TODO: This could be improved with a faster metric.
      edgeDistance0 = distanceToLine(intersection, lseg0);
      edgeDistance1 = distanceToLine(intersection, lseg1);
      if (isProper) {
        //TODO: Need to figure out where setBoundaryNodes is called.
        Iterable<Node> boundaryNodes = [edge0, edge1].expand((e) => e.parentGraph.boundaryNodes);
        isProperInterior = boundaryNodes.every((n) => n.coordinate != intersection);
      }
    } else if (intersection is LineSegment) {
      edgeDistance0 = lineToLineDistance(intersection, lseg0);
      edgeDistance1 = lineToLineDistance(intersection, lseg1);
    } else {
      assert(false);
    }
    
    //There must be an intersection
    IntersectionInfo isectInfo =
        new IntersectionInfo._(edge0, segIndex0, edgeDistance0, 
                               edge1, segIndex1, edgeDistance1,
                               intersection, 
                               isProper,
                               isProperInterior);
    
    return new Optional.of(isectInfo);
  }
}