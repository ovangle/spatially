part of spatially.geomgraph.geometry_graph;

class Edge extends graph.GraphEdge<List<Coordinate>> {

  List<Coordinate> get coordinates {
    if (forwardLabel.isPresent) {
      return (forwardLabel.value as EdgeLabel).coordinates;
    }
    return new List.from((backwardLabel.value as EdgeLabel).coordinates.reversed);
  }

  Edge(GeometryGraph graph,
       Optional<EdgeLabel> forwardLabel,
       Optional<EdgeLabel> backwardLabel,
       Node startNode,
       Node endNode) :
         super(graph, forwardLabel, backwardLabel, startNode, endNode);

  Optional<Location> forwardLocationAt(int locationIdx) =>
      forwardLabel.transform((lbl) => lbl.locationDatas.project(locationIdx));
  Optional<Location> backwardLocationAt(int locationIdx) =>
      backwardLabel.transform((lbl) => lbl.locationDatas.project(locationIdx));

  /**
   * Retrieves the intersection from an [IntersectionInfo].
   *
   * If the intersection is a line segment, reorients it (if necessary) so
   * that the start of the segment is closer to the start of the segment
   * of intersection.
   *
   * It assumes that the info applies to this edge and that the edge is positioned
   * at info.edge0
   */
  dynamic /* Coordinate | LineSegment */ _getIntersection(IntersectionInfo info) {
    var intersection = info.intersection;
    assert(identical(info.edge0, this));
    if (intersection is LineSegment) {
      var segStart = this.coordinates[info.segIndex0];
      if (segStart.distanceSqr(intersection.start) > segStart.distanceSqr(intersection.end))
        intersection = intersection.reversed;
    }
    return intersection;
  }

  Iterable<IntersectionInfo> _sortInfos(Iterable<IntersectionInfo> intersectionInfos) {
    var sortedInfos = intersectionInfos
      .where((info) => identical(info.edge0, this) || identical(info.edge1, this))
      .map((info) => info.edge0 == this ? info : info.symmetric)
      .toList(growable: false)
      //Sort the infos by their distance along the edgea
      ..sort((info1, info2) {
        var cmpSegs = info1.segIndex0.compareTo(info2.segIndex0);
        if (cmpSegs != 0) return cmpSegs;
        return info1.edgeDistance0.compareTo(info2.edgeDistance0);
      });

    var lastCoord;
    List<IntersectionInfo> uniqInfos = [];

    for (var info in sortedInfos) {
      var isect = _getIntersection(info);
      if (isect is Coordinate) {
        if (isect == lastCoord)
          continue;
        lastCoord = isect;
        uniqInfos.add(info);
      } else if (isect is LineSegment) {
         if (isect.start == lastCoord) {
          //Keep the line segments, remove the coordinates.
          uniqInfos.removeLast();
        }
        uniqInfos.add(info);
        lastCoord = isect.end;
      }
    }
    return uniqInfos;
  }

  Iterable<List<Coordinate>> splitCoordinates(Iterable<IntersectionInfo> intersectionInfos) {
    List<Coordinate> coords = this.coordinates;

    var splitStart = 0;
    var nextStartCoord = null;
    var lastIntersection;
    /*
     * The coordinates in the split at [:splitStart:], up
     * to the end of the intersection.
     */
    List<Coordinate> _coordsBeforeIntersection(IntersectionInfo info) {
      List<Coordinate> coordsBefore = [];
      if (nextStartCoord != null) {
        coordsBefore.add(nextStartCoord);
      }
      coordsBefore.addAll(coords.sublist(splitStart, info.segIndex0 + 1));

      var isect = _getIntersection(info);
      //Advance the pointer to the next split start
      if (isect is Coordinate) {
        if (isect != coordsBefore.last) {
          //Split in the middle of the segment
          coordsBefore.add(isect);
        }
        nextStartCoord = isect;
      } else if (isect is LineSegment) {
        var segStart = coords[info.segIndex0];
        if (isect.start != segStart) {
          //The intersection starts midway down the
          //current segment. There is still a coordinate
          //to add to the segment
          //Figure out the closest end of the segment
          coordsBefore.add(isect.start);
        } else if (coordsBefore.length <= 1) {
          //The segment appears at the start of the edge
          return [];
        }
      } else {
        //TypeError
        assert(false);
      }
      return coordsBefore;
    }

    /*
     * If the intersection is a linesegment, we also have
     * to create another split covering the portion of the line
     * which intersects
     */
    List<Coordinate> _coordsAtIntersection(IntersectionInfo info) {
      var isect = _getIntersection(info);
      if (isect is LineSegment) {
        var segStart = coordinates[info.segIndex0];
        nextStartCoord = isect.end;
        return [isect.start, isect.end];
      }
      return [];
    }

    if (intersectionInfos.isEmpty)
      return [coords];

    var sortedInfos = _sortInfos(intersectionInfos);

    var splitCoords =
        sortedInfos
        .expand((info) {
          var coordsBefore = _coordsBeforeIntersection(info);
          var coordsAfter = _coordsAtIntersection(info);
          return [coordsBefore, coordsAfter];
        })
        .where((coords) => coords.isNotEmpty)
        .toList(growable: false);

    //Add the coords after the last intersection
    var remainingCoords = [nextStartCoord];
    remainingCoords.addAll(coordinates.skip(splitStart));
    return [splitCoords, [remainingCoords]].expand((i) => i);
  }

  String toString() => "Edge($coordinates)";
}
