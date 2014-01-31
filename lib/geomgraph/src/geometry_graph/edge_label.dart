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


part of spatially.geomgraph.geometry_graph;

class Edge implements GraphEdgeLabel<Edge> {
  final GeometryGraph graph;

  /**
   * The delegate edge which applies to this label.
   */
  GraphEdge<Edge> get _delegate =>
      graph._delegate.edgeByLabel(this);

  final List<Coordinate> _coordinates;
  //Store the reversed coordinates on every label,
  //to make reversing the label O(1).
  final List<Coordinate> _revCoordinates;

  final Tuple<Location,Location> locations;

  UnmodifiableListView<Coordinate> get coordinates =>
      new UnmodifiableListView(_coordinates);

  Edge._(GeometryGraph this.graph,
         List<Coordinate> coords,
         Tuple<Location,Location> this.locations) :
    _coordinates = coords,
    _revCoordinates = new List.from(coords.reversed, growable: false);

  Edge._from(Edge label) :
    graph = label.graph,
    _coordinates = label._coordinates,
    _revCoordinates = label._revCoordinates,
    locations = label.locations;

  Edge._reversed(Edge label) :
    graph = label.graph,
    _coordinates = label._revCoordinates,
    _revCoordinates = label._coordinates,
    locations = label.locations;

  Node get startNode => _delegate.startNode.label;
  Node get endNode => _delegate.endNode.label;
  Iterable<Node> get terminatingNodes => _delegate.terminatingNodes.map((n) => n.label);

  bool get isDirected => _delegate.isDirected;

  Edge asDirected({bool asForward: true}) =>
      _delegate.asDirectedEdge(asForward: asForward).label;

  /**
   * Computes the (as yet unknown) location
   */
  void _fiinalizeLabel(int geomIdx) {

    int computeLocation() {
      //If the geometry is a linear geometry, any overlapping edges would have
      //been set during noding. `this` must be on the exterior.
      var g = graph.geometries.project(geomIdx);
      if (g is Point || g is Linestring
          || g is MultiPoint || g is MultiLinestring)
        return loc.EXTERIOR;

      var nodeLocations = terminatingNodes.map((n) => n.locations.project(geomIdx));

      //The graph has been noded, so if either terminating node is on the exterior
      //of the geometry, the entire edge must be an exterior edge
      if (nodeLocations.any((l) => l.on == loc.EXTERIOR))
        return loc.EXTERIOR;

      //Similarly, if either terminating node is on the interior, the edge
      //must be an interior edge.
      if (nodeLocations.any((l) => l.on == loc.INTERIOR))
        return loc.INTERIOR;

      //Both end locations were on the boundary. If we were also on the boundary,
      //the location would have been set while merging labels.
      //Choose a representative coordinate and use it's location as the location of the edge.
      var reprCoord =
          coordinateSegments(coordinates).first.midpoint;
      return locateCoordinateIn(reprCoord, g);
    }

    locations.project(geomIdx).on = computeLocation();
  }

  /**
   * Split the edge, adding a node at each of the intersection points
   * and an edge between each of the nodes.
   *
   * Also adds nodes and edges as required to ensure the uniqueness of edges
   * between any two nodes in the graph.
   */
  void _nodeEdge(Iterable<IntersectionInfo> intersectionInfos) {
    Iterable<List<Coordinate>> splitCoords = splitCoordinates(intersectionInfos);
    if (splitCoords.length == 1) {
      //No intersections apply to this edge -- skip it
      return;
    }
    assert(!isDirected);
    int geomIndex = locations.$1.isKnown ? 1 : 2;
    //Exactly one of the locations should always be known
    //during noding
    assert(locations.project(geomIndex).isKnown);
    assert(!locations.projectOther(geomIndex).isKnown);

    Location knownLoc = locations.project(geomIndex);

    GraphNode<Node> addIntersectionNode(Coordinate c) =>
        graph._addCoordinate(geomIndex, c, on: knownLoc.on);

    void addSplitEdge(List<Coordinate> coords) {
      assert(coords.length >= 2);
      var start = addIntersectionNode(coords.first);
      var end = addIntersectionNode(coords.last);
      var left, right;
      knownLoc.left.ifPresent((v) {
        left = v;
      });
      knownLoc.right.ifPresent((v) {
        right = v;
      });
      graph._addCoordinateList(geomIndex, coords, start, end,
          on: knownLoc.on, left: left, right: right);
    }
    graph._delegate.removeEdge(this);
    splitCoords.forEach(addSplitEdge);
  }


  /**
   * Retrieve the intersection from the info.
   * If necessary, reorient the linesegment intersection so that the start of the line
   * segment is closest to the start of the intersecting segment.
   * Assumes that `this` is the edge at info.edge0
   */
  dynamic /* Coordinate | LineSegment */ _getIntersection(IntersectionInfo info) {
    var isect = info.intersection;
    assert(identical(this, info.edge0));
    if (isect is LineSegment) {
      var start = coordinates[info.segIndex0];
      if (isect.start.distanceSqr(start) > isect.end.distanceSqr(start))
        isect = isect.reversed;
    }
    return isect;
  }

  /**
   * Sorts the intersections by their position along the edge and removes any
   * non-unique infos from the list.
   */
  Iterable<IntersectionInfo> _sortInfos(Iterable<IntersectionInfo> infos) {
    var sortedInfos = infos
        .map((info) => identical(info.edge0, this) ? info : info.symmetric)
        .where((info) => identical(info.edge0, this))
        .toList(growable: false)
        ..sort((info1, info2) {
          var cmpSegs = info1.segIndex0.compareTo(info2.segIndex0);
          if (cmpSegs != 0) return cmpSegs;
          return info1.edgeDistance0.compareTo(info2.edgeDistance0);
        });

    var lastSegStart, lastSegEnd;
    LinkedList<IntersectionInfo> uniqInfos = new LinkedList();
    for (var info in sortedInfos) {
      var isect = _getIntersection(info);
      if (isect is Coordinate) {
        if (isect == lastSegStart || isect == lastSegEnd)
          continue;
        lastSegStart = lastSegEnd = isect;
        uniqInfos.add(info);
      } else if (isect is LineSegment) {
        if (isect.start == lastSegEnd) {
          //Keep line segments, remove coordinates.
          uniqInfos.removeLast();
        }
        if (info.segIndex0 == coordinates.length - 2
            && isect.end == coordinates[0]) {
          uniqInfos.removeFirst();
        }
        uniqInfos.add(info);
        lastSegStart = isect.start;
        lastSegEnd = isect.end;
      }
    }
    return uniqInfos;
  }

  /**
   * Splits the coordinates of the edge at each position where an
   * intersection was recorded by the edge set intersector.
   *
   * Coordinates are split inclusively so the end of each split contains
   * the start of the next one (and vice versa).
   */
  Iterable<List<Coordinate>> splitCoordinates(Iterable<IntersectionInfo> infos) {
    var nextStartCoord;
    int splitStart = 0;

    // Collects coordinates from the list of intersection infos
    // begining with the end of the last intersection and ending
    // at the start of the intersection.
    List<Coordinate> coordsBefore(IntersectionInfo info) {

      List<Coordinate> coordsBefore = [];
      if (nextStartCoord != null)
        coordsBefore.add(nextStartCoord);
      if (nextStartCoord == coordinates[splitStart]) {
        splitStart++;
      }

      if (splitStart <= info.segIndex0)
        coordsBefore.addAll(slice(coordinates, splitStart, info.segIndex0));

      var isect = _getIntersection(info);
      if (isect is Coordinate) {
        if (splitStart <= info.segIndex0
              && isect != coordinates[info.segIndex0]) {
          coordsBefore.add(coordinates[info.segIndex0]);
        }
        if (coordsBefore.isNotEmpty) {
          coordsBefore.add(isect);
        }
        nextStartCoord = isect;
      } else if (isect is LineSegment) {
        if (splitStart <= info.segIndex0
              && isect.start != coordinates[info.segIndex0]) {
          coordsBefore.add(coordinates[info.segIndex0]);
        }
        if (coordsBefore.isNotEmpty) {
          coordsBefore.add(isect.start);
        }
        nextStartCoord = isect.end;
      } else {
        assert(false);
      }
      splitStart = info.segIndex0 + 1;
      return coordsBefore;
    }

    /*
     * If the intersection is a linesegment, we also have
     * to create another split covering the portion of the line
     * which intersects
     */
    List<Coordinate> coordsAt(IntersectionInfo info) {
      var isect = _getIntersection(info);
      if (isect is LineSegment) {
        return [isect.start, isect.end];
      }
      return [];
    }

    if (infos.isEmpty) return [coordinates];

    var splitCoords =
        _sortInfos(infos)
        .expand((info) => [coordsBefore(info), coordsAt(info)])
        .where((coords) => coords.isNotEmpty)
        .toList();

    //There was only one intersection, at the start of the first
    //segment.
    if (splitCoords.isEmpty)
      return [coordinates];

    //Add the coords after the last intersection
    var remainingCoords =
        coordinates.skip(splitStart)
        .where((c) => !splitCoords.last.contains(c));

    if (remainingCoords.isEmpty)
      return splitCoords;
    var lastSplit = [];
    if (nextStartCoord != remainingCoords.first) {
      lastSplit.add(nextStartCoord);
    }
    lastSplit.addAll(remainingCoords);
    splitCoords.add(lastSplit);
    return splitCoords;
  }

  Edge get reversed => new Edge._reversed(this);

  Edge merge(Edge label) {
    var mergedLocations;
    if (_listEq.equals(coordinates, label._coordinates)) {
      mergedLocations =
          new Tuple(
              new Location.merged(locations.$1, label.locations.$1),
              new Location.merged(locations.$2, label.locations.$2));
    } else if (_listEq.equals(coordinates, label._revCoordinates)) {
      mergedLocations =
          new Tuple(
              new Location.merged(locations.$1, label.locations.$1.flipped),
              new Location.merged(locations.$2, label.locations.$2.flipped));
    } else {
      throw new ArgumentError("Can only merge labels with equal coords");
    }
    return new Edge._(graph, coordinates, mergedLocations);
  }

  /**
   * Compares edges by the position around the node via a simple sweepline algorithm.
   * The sweepline begins along the negative x-axis and sweeps in an anti-clockwise
   * direction. Edges are ordered by the temporal order in which the sweepline
   * crosses the first coordinate in the edge away from the node.
   */
  int compareOrientation(Node node, Edge edge) {
    if (this == edge)
      return 0;
    //The line segment between the node and the ith
    //coordinate of edge.
    LineSegment _rayToCoord(Edge e, i) {
      assert(e.terminatingNodes.contains(node));
      var coord = (
          node.coordinate == e._coordinates.first
            ? e._coordinates[i]
            : e._revCoordinates[i]);
      return new LineSegment(node.coordinate, coord);
    }
    int i = 1;
    var thisRay, otherRay;
    while (i < this.coordinates.length
           && i < edge.coordinates.length) {
      thisRay = _rayToCoord(this, i);
      otherRay = _rayToCoord(edge, i);
      var cmp = thisRay.angle.compareTo(otherRay.angle);
      if (cmp != 0)
        return cmp;
      i++;
    }
    if (i < this.coordinates.length)
      return -1;
    if (i < edge.coordinates.length)
      return 1;
    return thisRay.magnitude.compareTo(otherRay.magnitude);
  }

  bool operator ==(Object other) =>
      other is Edge
      && _listEq.equals(_coordinates, other._coordinates);

  int get hashCode => _listEq.hash(_coordinates);

  String toString() => "edge: $_coordinates";
}