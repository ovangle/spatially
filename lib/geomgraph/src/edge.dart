part of geomgraph._base;

class Edge extends GraphComponent {
  Edge(Label label) : super(label);
}

/**
 * An [EdgeEnd] represents the end of an [Edge]
 * where it ends at a node.
 * 
 * [EdgeEnd]s are ordered by the angle the line which
 * extends from the [EdgeEnd] to the other [EdgeEnd]
 * makes with the positive x-axis.
 */
class EdgeEnd implements Comparable<EdgeEnd> {
  //The parent edge of this [EdgeEnd]
  final Edge edge;
  final Label label;
  final Coordinate c0;
  final Coordinate c1;
  
  Node get node;
  EdgeEnd(Edge edge) :
    this.edge = edge,
    label = edge.label,
    c0 = edge.coordinate,
    c1 = edge.coordinate;
  
  /**
   * The angle the directed linesegment defined
   * by (c0 -> c1) makes with the positive x-axis.
   * as a number in the range [0, 2 * PI)
   */
  double get dt {
    final dx = c1.x - c0.x;
    final dy = c1.y - c0.y;
    var dt = math.atan2(dy, dx);
    //Negative coordinates should be in the range
    // [PI, 2 * PI) so that angles closer to the positive
    // axis get sorted first.
    return (dt < 0) ? dt + 2 * math.PI : dt;
  }
  
  int compareTo(EdgeEnd edgeEnd) =>
      dt.compareTo(edgeEnd.dt);
  
  bool operator ==(EdgeEnd other) => compareTo(other) == 0;
  
  String toString() =>
      "${runtimeType}: $c0 -> $c1, label: $label";
}

/**
 * A sorted list of [EdgeEnd]s around a [Node]s
 * Maintained in counter-clockwise order (starting with the 
 * positive x-axis) around the node
 */
class EdgeEndStar extends Object with ListMixin<EdgeEnd> {
  SplayTreeMap<EdgeEnd, dynamic> edgeMap;
  
  EdgeEnd operator [](int i) =>
      edgeMap.keys.elementAt(i);
  void operator []=(int i, EdgeEnd edge) {
    edgeMap[edge] = null;
  }
  /**
   * The coordinate for the [Node] `this` is based at
   */
  Coordinate get coordinate {
    if (isEmpty) return null;
    return first.node.coordinate;
  }
  
  int get length => edgeMap.keys.length;
      set length(int newLength) {
        throw new UnsupportedError("Cant set length of EdgeEndStar");
      }
      
  /**
   * The number of edges which end at `this`.
   */
  int get degree => length;
  
  /**
   * Returns the edge directly clockwise of the given [:edgeEnd:]
   * Throws a [StateError] if the edgeEnd is not in `this`
   */
  EdgeEnd edgeClockwiseOf(EdgeEnd edgeEnd) =>
      edgeMap.lastKeyBefore(edgeEnd);
  
  /**
   * The edge directly counter-clockwise of the given [:edgeEnd:]
   * Throws a [StateError] if the edgeEnd is not in `this`
   */
  EdgeEnd edgeCounterClockwiseOf(EdgeEnd edgeEnd) =>
      edgeMap.firstKeyAfter(edgeEnd);
}