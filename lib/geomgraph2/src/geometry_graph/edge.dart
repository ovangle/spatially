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

  List<List<Coordinate>> splitCoordinates(Iterable<IntersectionInfo> intersectionInfos) {
    var coords = this.coordinates;
    var splitStart = 0, nextStartCoord;

    /*
     * The coordinates in the split at [:splitStart:], up
     * to the end of the intersection.
     */
    List<Coordinate> _coordsBeforeIntersection(IntersectionInfo info) {
      List<Coordinate> coordsBefore = [];

      if (nextStartCoord != null) {
        //Some of the last segment was left over after the split.
        coordsBefore.add(nextStartCoord);
      }
      coordsBefore.addAll(coords.sublist(splitStart, info.segIndex0 + 1));
      //Advance the pointer to the next split start
      if (info.intersection is Coordinate) {
        if (info.intersection != coordsBefore.last) {
          //Split in the middle of the segment
          coordsBefore.add(info.intersection);
        }
        nextStartCoord = info.intersection;
      } else if (info.intersection is LineSegment) {
        var segStart = coords[info.segIndex0];
        if (info.intersection.start != segStart
            && info.intersection.end != segStart) {
          //The intersection starts midway down the
          //current segment. There is still a coordinate
          //to add to the segment
          //Figure out the closest end of the segment
          var distToStart = info.intersection.start.distanceSqr(segStart);
          var distToEnd = info.intersection.end.distanceSqr(segStart);
          if (distToStart <= distToEnd) {
            coordsBefore.add(info.intersection.start);
          } else {
            //Add the segment in reverse.
            coordsBefore.add(info.intersection.end);
          }
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
      if (info.intersection is LineSegment) {
        var segStart = coordinates[info.segIndex0];
        var distToStart = segStart.distanceSqr(info.intersection.start);
        var distToEnd = segStart.distanceSqr(info.intersection.end);

        if (distToStart < distToEnd) {
          nextStartCoord = info.intersection.end;
          return [info.intersection.start, info.intersection.end];
        } else if (distToStart > distToEnd) {
          nextStartCoord = info.intersection.start;
          return [info.intersection.end, info.intersection.start];
        } else {
          nextStartCoord = segStart;
        }
      }

      //Coordinate or segment with 0 length
      return [];
    }

    var sortedInfos =
        intersectionInfos
        .where((info) => identical(info.edge0, this) || identical(info.edge1, this))
        .map((info) => info.edge0 == this ? info : info.symmetric)
        .toList(growable: false)
        //Sort the infos by their distance along the edgea
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
      //There was never a reason to split the edge
      return [coords];
    }
    //Add the coords after the last intersection
    var remainingCoords = [nextStartCoord];
    remainingCoords.addAll(coordinates.skip(splitStart));
    splitCoords.add(remainingCoords);
    return splitCoords;
  }
}

class EdgeLabel extends GeometryLabelBase<List<Coordinate>> {
  List<Coordinate> coordinates;

  EdgeLabel(List<Coordinate> this.coordinates,
            Tuple<Location,Location> locationDatas) :
    super(locationDatas);

  bool operator ==(Object other) {
    if (other is EdgeLabel) {
      if (other.coordinates.length != coordinates.length)
        return false;
      return zip(coordinates, other.coordinates)
          .every((elem) => elem.$1 == elem.$2);
    }
    return false;
  }

  int get hashCode => hashObjects(coordinates);
}