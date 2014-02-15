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

part of spatially.geomgraph.intersector;


class IntersectionInfo {
  /**
   * The edge being intersected
   */
  Edge edge0; int segIndex0; double edgeDist0;

  /**
   * The edge being intersected with
   */
  Edge edge1; int segIndex1; double edgeDist1;

  List<Coordinate> coordinates;

  Iterable<LineSegment> get segments => coordinateSegments(coordinates);

  IntersectionInfo._(Edge this.edge0, int this.segIndex0, double this.edgeDist0,
                 Edge this.edge1, int this.segIndex1, double this.edgeDist1,
                 List<Coordinate> this.coordinates);

  /**
   * Create a new Intersection by intersecting two edges of a graph.
   */
  factory IntersectionInfo(Edge edge0, int segIndex0,
                           Edge edge1, int segIndex1) {
    //We're not interested in the intersection of a segment with itself.
    if (identical(edge0, edge1) && segIndex0 == segIndex1) return null;

    var segs0 = coordinateSegments(edge0.coordinates);
    var segs1 = coordinateSegments(edge1.coordinates);

    LineSegment lseg0 = segs0.elementAt(segIndex0);
    LineSegment lseg1 = segs1.elementAt(segIndex1);

    var intersection = li.segmentIntersection(lseg0, lseg1);
    if (intersection == null) return null;

    double edgeDist0, edgeDist1;
    List<Coordinate> coords;

    //TypeError
    assert(intersection is Coordinate || intersection is LineSegment);

    if (intersection is LineSegment) {
      if (intersection.magnitude > 0) {
        edgeDist0 = math.min(intersection.start.distanceSqr(lseg0.start),
                             intersection.end.distanceSqr(lseg0.start));
        edgeDist1 = math.min(intersection.start.distanceSqr(lseg1.start),
                             intersection.end.distanceSqr(lseg1.start));
        coords = [intersection.start, intersection.end];
      } else {
        intersection = intersection.start;
      }
    }

    if (intersection is Coordinate) {
      //Check if the intersection is just the adjacency of two segments.
      if (identical(edge0, edge1)) {
        if ((segIndex0 - segIndex1).abs() == 1)
          return null;
        if (edge0.coordinates.first == edge0.coordinates.last
            && (segIndex0 - segIndex1).abs() == segs0.length - 1)
          return null;
      }
      edgeDist0 = lseg0.start.distanceSqr(intersection);
      edgeDist1 = lseg1.start.distanceSqr(intersection);
      coords = [intersection];
    }

    return new IntersectionInfo._(edge0, segIndex0, edgeDist0,
                                  edge1, segIndex1, edgeDist1,
                                  coords);
  }

  bool get isCoordinateIntersection => coordinates.length == 1;
  bool get isLineIntersection => coordinates.length > 1;

  Coordinate get start => coordinates.first;
  Coordinate get end => coordinates.last;

  /**
   * The intersection, with the roles of primary and secondary edges reversed
   */
  IntersectionInfo get symmetric =>
      new IntersectionInfo._(edge1, segIndex1, edgeDist1,
                         edge0, segIndex0, edgeDist0,
                         coordinates);

  /**
   * An intersection with the same primary and secondary segments, but with
   * the coordinates reversed
   */
  IntersectionInfo get reversed =>
      new IntersectionInfo._(edge0, segIndex0, edgeDist0,
                         edge1, segIndex1, edgeDist1,
                         new List.from(coordinates.reversed, growable: false));

  IntersectionInfo _append(IntersectionInfo info) {
    assert(identical(edge0, info.edge0));
    assert(identical(edge1, info.edge1));
    assert(end == info.start);
    return new IntersectionInfo._(
        edge0, segIndex0, edgeDist0,
        edge1, segIndex1, edgeDist1,
        concat([coordinates, info.coordinates.skip(1)]).toList(growable: false));
  }

  static const _listEq = const ListEquality();

  /**
   * Two edge intersections are equal if
   */
  bool operator ==(Object other) {
    if (other is IntersectionInfo) {
      if (!_listEq.equals(coordinates, other.coordinates)) {
        return false;
      }
      if (identical(edge0, edge1)) {
        return (segIndex0 == other.segIndex0 && segIndex1 == other.segIndex1)
            || (segIndex0 == other.segIndex1 && segIndex1 == other.segIndex0);
      }
      if (identical(edge0, other.edge0) && identical(edge1, other.edge1)) {
        return segIndex0 == other.segIndex0 && segIndex1 == other.segIndex1;
      }
      if (identical(edge0, other.edge1) && identical(edge1, other.edge0)) {
        return segIndex1 == other.segIndex0 && segIndex0 == other.segIndex1;
      }
    }
    return false;
  }

  var _cachedHashCode = null;
  int get hashCode {
    if (_cachedHashCode == null) {
      int coordsHash = _listEq.hash(coordinates);
      var h1 =  31 + edge0.hashCode;
      h1 = h1 * 31 + segIndex0.hashCode;
      var h2 = 31 + edge1.hashCode;
      h2 = h2 * 31 + segIndex1.hashCode;
      _cachedHashCode = coordsHash + h1 + h2;
    }
    return _cachedHashCode;
  }

  String toString() => "($edge0:$segIndex0)&($edge1:$segIndex1):$coordinates";
}

class IntersectionSet extends DelegatingSet<IntersectionInfo> {
  IntersectionSet._(Iterable<IntersectionInfo> intersections) :
      super(intersections.toSet());

  //IntersectionLists created with a default constructor are growable.
  //Other intersection lists aren't.
  IntersectionSet() : super(new HashSet());

  factory IntersectionSet.fromGraph(GeometryGraph graph) {
    List<Edge> edges = graph.edges.toList(growable:false);
    var intersections = edgeSetIntersector(edges);
    return new IntersectionSet._(intersections);
  }
}

/**
 * An [EdgeIntersectionList] is a list of intersections, arranged so
 * that each intersection shares the same dominant edge and the intersections
 * are ordered such that
 */
class EdgeIntersectionList extends DelegatingList<IntersectionInfo> {
  EdgeIntersectionList._(Iterable<IntersectionInfo> intersections) :
    super(intersections.toList(growable: false));

  static List<IntersectionInfo> _sortAlong(Edge edge, Iterable<IntersectionInfo> infos) {

    //Reorients the intersection so that the dominant edge is the edge we're sorting along
    //And reverses the coordinate list so that the intersection lies in the same direction
    //as the edge.
    IntersectionInfo reorientIntersection(IntersectionInfo info) {
      if (!identical(info.edge0, edge)) {
        info = info.symmetric;
      }
      if (info.isLineIntersection) {
        var intersectionSeg = info.segments.first;
        var segStart = edge.coordinates[info.segIndex0];
        if (intersectionSeg.start.distanceSqr(segStart) > intersectionSeg.end.distanceSqr(segStart)) {
          info = info.reversed;
        }
      }
      return info;
    }

    int _compareIntersections(IntersectionInfo info1, IntersectionInfo info2) {
      var cmpSegs = info1.segIndex0.compareTo(info2.segIndex0);
      if (cmpSegs != 0) return cmpSegs;
      return info1.edgeDist0.compareTo(info2.edgeDist0);
    }

    return infos
        .where((info) => identical(info.edge0, edge) || identical(info.edge1, edge))
        .map(reorientIntersection)
        .toList(growable: false)
        ..sort(_compareIntersections);
  }

  static Iterable<IntersectionInfo> _chain(Edge edge, Iterable<IntersectionInfo> infos) {
    LinkedList<IntersectionInfo> uniqInfos = new LinkedList<IntersectionInfo>();
    var lastSegStart,lastSegEnd;
    for (var isect in infos) {
      if (isect.isCoordinateIntersection) {
        if (isect.start == lastSegStart
            || isect.start == lastSegEnd)
          continue;
      }
      if (isect.isLineIntersection) {

        while (isect.segIndex0 == edge.coordinates.length - 2
            && uniqInfos.isNotEmpty
            && uniqInfos.first.isCoordinateIntersection
            && uniqInfos.first.start == isect.end) {
          uniqInfos.removeFirst();
        }
        if (isect.start == lastSegEnd) {
          isect = uniqInfos.removeLast()._append(isect);
        }
      }
      lastSegStart = isect.start;
      lastSegEnd = isect.end;
      uniqInfos.add(isect);
    }
    return new EdgeIntersectionList._(uniqInfos);
  }

  factory EdgeIntersectionList(IntersectionSet graphIntersections, Edge edge) {
    List<IntersectionInfo> sortedInfos = _sortAlong(edge,graphIntersections);
    return _chain(edge, sortedInfos);
  }
}
