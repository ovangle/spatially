part of geomgraph.edge;

class EdgeIntersections extends Object with IterableMixin<EdgeIntersection> {
  final Edge parentEdge;
  final List<EdgeIntersection> _delegate;
  
  EdgeIntersections(Edge this.parentEdge) :
    _delegate = new List<EdgeIntersection>();
  
  Iterator<EdgeIntersection> get iterator => _delegate.iterator;
  
  void add(dynamic /*Coordinate|LineSegment*/intersection, int segmentIndex, double dist) {
    EdgeIntersection ei = new EdgeIntersection._(intersection, segmentIndex, dist);
    int i = -1; 
    while(++i < _delegate.length
          && _delegate[i].compareTo(ei) <= 0);
    if (_delegate[i].compareTo(ei) != 0) {
      _delegate.insert(i, ei);
    }
  }
  
  void _addEndpoints() {
    add(parentEdge.coordinates.first, 0, 0.0);
    //The index of the last endpoint is larger than the index
    //of any segment in the parent edge.
    //So it will always sort higher than any other intersection
    add(parentEdge.coordinates.last, parentEdge.coordinates.length - 1, 0.0);
  }
  
  /**
   * `true` if the coordinate is equal to any coordinate intersection
   * or the start point of any collinear intersection
   */
  bool isIntersection(Coordinate c) => any((ei) => ei.coordinate == c);
  
  /**
   * Returns a planar graph, with nodes at each of the intersection
   * points of the edge, and an edge between each pair of consecutive
   * intersection points.
   * 
   * All locations on the returned graph will have loc.NONE on all
   * [Node]s and [Edge]s. 
   */
  PlanarGraph splitEdge() {
    _addEndpoints();
    PlanarGraph edgeGraph = new PlanarGraph();
    Geometry componentGeom = parentEdge.label.componentOf;
    for (var ei in this) {
      edgeGraph.addNode(componentGeom, 
                        ei.coordinate);
    }
    for (var i in range(1, this.length)) {
      final ei0 = _delegate[i-1];
      final ei1 = _delegate[i];
      
      var edgeCoords = new List<Coordinate>();
      edgeCoords.add(ei0.coordinate);
      edgeCoords.addAll(parentEdge.coordinates.sublist(ei0.segmentIndex, ei1.segmentIndex + 1));
      if (ei1.dist > 0.0 || ei1.coordinate != edgeCoords.last) {
        edgeCoords.add(ei1);
      }
      var coords = new Array.from(edgeCoords);
      edgeGraph.addLinearEdge(componentGeom, coords);
    }
    return edgeGraph;
  }
}

class EdgeIntersection implements Comparable<EdgeIntersection> {
  /**
   * The intersection 
   */
  final /* Coordinate | LineSegment */ intersection;
  /**
   * The index of the segment in the [Edge]
   * containing this intersection
   */
  final int segmentIndex;
  
  /**
   * The edge distance along the containing line segment
   */
  final double dist;
  
  EdgeIntersection._(this.intersection, 
                     int this.segmentIndex, 
                     double this.dist);
  
  /**
   * If [intersection] is a [Coordinate], returns the intersection
   * If [intersection] is a [LineSegment], 
   * returns the start point of the intersection
   */
  Coordinate get coordinate {
    if (intersection is Coordinate) {
      return intersection;
    } else if (intersection is LineSegment) {
      return intersection.start;
    } else {
      throw new StateError("Intersection must either a Coordinate or LineSegment");
    }
  }
  
  int compareTo(EdgeIntersection other) {
    var cmpIndexes = segmentIndex.compareTo(other.segmentIndex);
    if (cmpIndexes != 0) return cmpIndexes;
    return dist.compareTo(other.dist);
  }
  
  bool operator ==(Object other) {
    if (other is EdgeIntersection) {
      return intersection == other.intersection
          && segmentIndex == other.segmentIndex
          && dist == other.dist;
    }
    return false;
  }
  
  int get hashCode {
    int hashCode = 7;
    hashCode += hashCode * 7 + intersection.hashCode;
    hashCode += hashCode * 7 + segmentIndex.hashCode;
    hashCode += hashCode * 7 + dist.hashCode;
    return hashCode;
  }
  
  String toString() => "$intersection #$segmentIndex $dist";
}