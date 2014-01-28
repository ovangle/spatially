part of spatially.geomgraph.geometry_graph;

class Edge implements GraphEdgeLabel<Edge> {
  final GeometryGraph graph;

  /**
   * The delegate edge which applies to this label.
   */
  GraphEdge<Edge> get _delegate =>
      graph.delegate.edgeByLabel(this);

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
    _revCoordinates = new List.from(coords, growable: false);

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
      var connection = start.connection(end);
      if (connection != null
            && !_listEq.equals(connection.label.coordinates, coords)
            && !_listEq.equals(connection.label._revCoordinates, coords)) {
        //There's already an edge in the graph between these two nodes.
        //Split the coordinates equally either side of the midpoint.
        var len = coords.length;
        var mid;
        if (len % 2 == 0) {
          mid = new LineSegment(coords[len ~/ 2 - 1], coords[len ~/ 2]).midpoint;
        } else {
          mid = coords[len ~/ 2];
        }
        var initCoords =
            concat([coords.take(coords.length ~/ 2), [mid]])
            .toList(growable: false);
        print("INIT COORDS: $initCoords");
        var lastCoords =
            concat([[mid], coords.skip(coords.length ~/ 2)])
            .toList(growable: false);
        print("LAST COORDS: $lastCoords");
        addSplitEdge(initCoords);
        addSplitEdge(lastCoords);
        return;
      }
      graph._addCoordinateList(geomIndex, coords, start, end,
          on: knownLoc.on, left: left, right: right);
    }
    graph.delegate.removeEdge(this);
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

  Iterable<List<Coordinate>> splitCoordinates(Iterable<IntersectionInfo> infos) {
    var nextStartCoord;
    int splitStart = 0;

    List<Coordinate> coordsBefore(IntersectionInfo info) {
      List<Coordinate> coordsBefore = [];
      if (nextStartCoord != null)
        coordsBefore.add(nextStartCoord);
      if (nextStartCoord == coordinates[splitStart]) {
        splitStart++;
      }
      coordsBefore.addAll(coordinates.getRange(splitStart, info.segIndex0 + 1));
      splitStart = info.segIndex0 + 1;

      var isect = _getIntersection(info);
      if (isect is Coordinate) {
        if (isect != coordsBefore.last)
          coordsBefore.add(isect);
        nextStartCoord = isect;
      } else if (isect is LineSegment) {
        var start = coordinates[info.segIndex0];
        if (isect.start != start) {
          //The intersection starts midway down the
          //current segment. There is still a coordinate
          //to add to the segment
          //Figure out the closest end of the segment
          coordsBefore.add(isect.start);
        } else if (coordsBefore.length <= 1) {
          //The segment appears at the start of the segment
          //and there was a previous intersection at the start
          return [];
        }
      } else {
        assert(false);
      }
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
        nextStartCoord = isect.end;
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

  bool operator ==(Object other) =>
      other is Edge
      && _listEq.equals(_coordinates, other._coordinates);

  int get hashCode => _listEq.hash(_coordinates);

  String toString() => "edge: $_coordinates";
}