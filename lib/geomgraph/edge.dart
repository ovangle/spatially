library geomgraph.edge;

import 'dart:collection';

import 'package:quiver/core.dart';
import 'package:quiver/iterables.dart';

import 'package:spatially/base/coordinate.dart';
import 'package:spatially/base/line_segment.dart';

import 'package:spatially/algorithm/cg_algorithms.dart'
    as cg_algorithms;

import 'node.dart';
import 'label.dart';
import '../geomgraph2/intersector.dart';
import 'planar_graph.dart';

part 'src/edge/directed_edge.dart';

class Edge {
  PlanarGraph parentGraph;
  DirectedEdge _forward;
  DirectedEdge _backward;

  Label forwardLabel0;
  Optional<Label> forwardLabel1;

  UnmodifiableListView<Coordinate> _coordinates;

  Edge(PlanarGraph parentGraph,
       DirectedEdge forward,
       DirectedEdge backward,
       Iterable<Coordinate> coordinates) :
    this.parentGraph = parentGraph,
    this._forward = forward,
    this._backward = backward,
    this._coordinates = new UnmodifiableListView(coordinates);


  UnmodifiableListView<Coordinate> get coordinates =>
     _coordinates;
  void set coordinates(Iterable<Coordinate> coords) {
    this._coordinates = new UnmodifiableListView(coords);
  }

  bool get isPlanar => forwardLabel0.isPlanar;

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

  /**
   * Splits the coordinate list of the edge into an iterable containing
   * the coordinates between each intersection in the list of intersectionInfos.
   * The list begins with the coordinates from the start of the edge to the first intersection
   * and ends with the coordinates after the last intersection to the end of the edge.
   */
  List<List<Coordinate>> splitCoordinates(Iterable<IntersectionInfo> intersectionInfos) {
    var splitStart = 0;
    var nextStartCoord;

    /*
     * Returns the coordinates in the split starting at [:splitStart:]
     * and up to the end of the intersection.
     */
    List<Coordinate> _coordsBeforeIntersection(IntersectionInfo info) {
      List<Coordinate> coordsBefore = [];
      if (nextStartCoord != null) {
        //Some of the last segment was left over after the last split
        coordsBefore.add(nextStartCoord);
      }
      coordsBefore.addAll(coordinates.sublist(splitStart, info.segIndex0 + 1));
      //Advance the pointer to the next split start.
      splitStart = info.segIndex0 + 1;
      if (info.intersection is Coordinate) {
        if (info.intersection != coordsBefore.last) {
          coordsBefore.add(info.intersection);
        }
        nextStartCoord = info.intersection;
      } else if (info.intersection is LineSegment) {
        var segStart = coordinates[info.segIndex0];
        if (info.intersection.start != segStart
            && info.intersection.end != segStart) {
          var distToStart = info.intersection.start.distanceSqr(segStart);
          var distToEnd = info.intersection.end.distanceSqr(segStart);
          if (distToStart <= distToEnd) {
            coordsBefore.add(info.intersection.start);
          } else {
            //The intersection was in the opposite direction to the edge coordinates.
            //Add it in reverse.
            coordsBefore.add(info.intersection.end);
          }
        }
      } else {
        assert(false);
      }
      return coordsBefore;
    }

    /*
     * If the intersection is a line segment, we also have to create
     * another split covering the portion of the line segment which
     * intersects.
     */
    List<Coordinate> _coordsAtIntersection(IntersectionInfo info) {
      if (info.intersection is LineSegment) {
        var segStart = coordinates[info.segIndex0];
        var distToStart = segStart.distanceSqr(info.intersection.start);
        var distToEnd = segStart.distanceSqr(info.intersection.end);
        if (distToStart < distToEnd) {
          nextStartCoord = info.intersection.end;
          return [info.intersection.start, info.intersection.end];
        } else if (distToEnd > distToStart) {
          nextStartCoord = info.intersection.start;
          return [info.intersection.end, info.intersection.start];
        } else {
          nextStartCoord = segStart;
        }
      }
      //coordinate or segment with 0 length
      return [];
    }

    var sortedInfos =
        intersectionInfos
        //We are only interested in intersections involving the current edge
        .where((info) => info.edge0 == this || info.edge1 == this)
        .map((info) => info.edge0 == this ? info : info.symmetric)
        .toList(growable: false)
        //Sort the infos by their distance along the edge.
        ..sort((info1, info2) {
          var cmpSegs = info1.segIndex0.compareTo(info2.segIndex0);
          if (cmpSegs != 0) return cmpSegs;
          return info1.edgeDistance0.compareTo(info2.edgeDistance0);
        });

    var splitCoords =
        sortedInfos
        .expand((info) => [_coordsBeforeIntersection(info), _coordsAtIntersection(info)])
        .where((coords) => coords.isNotEmpty)
        .toList();

    if (nextStartCoord == null) {
      //We never had to split the edge.
      return [coordinates];
    } else {
      //Add the coords after the last intersection
      var remainingCoords = [nextStartCoord];
      remainingCoords.addAll(coordinates.skip(splitStart));
      splitCoords.add(remainingCoords);
    }
    return splitCoords;
  }

  /**
   * Two edges are equal if their coordinates are equal, or one has
   * the reverse of the coordinates of the other.
   */
  bool operator ==(Object other) {
    if (other is Edge) {
      if (coordinates.length != other.coordinates.length) return false;
      bool equalsForward = true;
      bool equalsReverse = true;
      for (int i=0;i<coordinates.length;i++) {
        if (coordinates[i] != other.coordinates[i]) {
          equalsForward = false;
        }
        if (coordinates[i] != other.coordinates[coordinates.length - i - 1]) {
          equalsReverse = false;
        }
        if (!equalsForward && !equalsReverse) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  bool isPointwiseEqual(Edge e) {
    if (coordinates.length != e.coordinates.length) return false;
    return range(coordinates.length)
        .every((i) => coordinates[i] == e.coordinates[i]);
  }

}