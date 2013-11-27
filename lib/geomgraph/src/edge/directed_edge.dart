part of geomgraph.edge;

class DirectedEdge {
  
  Edge _parentEdge;
  Edge get parentEdge => _parentEdge;
  /**
   * The node at the start of the edge
   */
  final Node startNode;
  /**
   * The node at the end of the edge
   */
  final Node endNode;
  /**
   * A vector parallel the first segment of the
   * linestring or ring represented by the edge, 
   * in the direction of the edge.
   */
  final Coordinate directionVector;
  
  bool _isForward;
  
  /**
   * Is this the forward direction vector of the
   * parent edge?
   */
  bool get isForward => _isForward;
  
  /**
   * Is this the backward direction vector of the
   * parent edge?
   */
  bool get isBackward => !_isForward;
  
  /**
   * The end of the direction vector.
   */
  final Coordinate _dirVectorEnd;
  
  DirectedEdge(Node startNode, 
               Node endNode,
               Coordinate directionVector) :
    this.startNode  = startNode,
    this.endNode    = endNode,
    this.directionVector = directionVector,
    _dirVectorEnd = new Coordinate(
        startNode.coordinate.x + directionVector.x,
        startNode.coordinate.y + directionVector.y);
  
  
  UnmodifiableListView<Coordinate> get coordinates =>
      isForward ? parentEdge.coordinates
                : new UnmodifiableListView(parentEdge.coordinates.reversed);
  
  Label get label => parentEdge.label;
  void set label(Label label) {
    parentEdge.label = label;
  }
  
  int get _quadrant {
    if (directionVector.y >= 0) {
      return (directionVector.x >= 0) ? 1 /* NE */ : 2 /* NW */;
    } else {
      return (directionVector.x >= 0) ? 4 /* SE */ : 3 /* SW */;
    }
  }
  
  /**
   * Returns the edge in the opposite direction
   * from this edge.
   */
  DirectedEdge get symmetricEdge =>
      isForward ? parentEdge.backward : parentEdge.forward;
  
  /**
   * The angle that `this` makes with the positive x-axis
   * as a number between 0 and 2*PI
   */
  double get angle =>
     math.atan2(directionVector.y, directionVector.x);
  
  /**
   * [DirectedEdge]s have a [compareTo] method, which compares
   * their direction. Their [angle]s aren't used directly,
   * since trigonometric functions are susceptible to roundoff
   * error.
   * 
   * Note that [DirectedEdge]s do not implement the [Comparable]
   * interface. Comparing two directed edges is only valid
   * when they share the same [startNode], so the [compareTo]
   * function is not total.
   * 
   * An [AssertionError] is raised in checked mode if the above
   * condition is not met.
   */
  int compareTo(DirectedEdge de) {
    //We should only ever be comparing directed edges
    //if they start at the same coordinate
    assert(startNode.coordinate == de.startNode.coordinate);
    var cmpQuadrants = Comparable.compare(_quadrant, de._quadrant);
    if (cmpQuadrants != 0) return cmpQuadrants;
    
    return cg_algorithms.orientationIndex(
                startNode.coordinate,
                de._dirVectorEnd,
                _dirVectorEnd);
  }
  
  /**
   * Removes `this` from the graph. 
   * Also removes the parent and symmetric edge if
   * the parent is non-null.
   */
  void remove() {
    if (_parentEdge != null) {
      _parentEdge.remove();
      _parentEdge = null;
    }
  }
}