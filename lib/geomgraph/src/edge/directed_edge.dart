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
   * The first segment of the edge represented
   * by this vector.
   */
  final LineSegment directionVector;

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

  DirectedEdge(Node startNode,
               Node endNode,
               LineSegment directionVector) :
    this.startNode  = startNode,
    this.endNode    = endNode,
    this.directionVector = directionVector;


  UnmodifiableListView<Coordinate> get coordinates =>
      isForward ? parentEdge.coordinates
                : new UnmodifiableListView(parentEdge.coordinates.reversed);

  Label get label0 =>
      isBackward ? parentEdge.forwardLabel0.flipped : parentEdge.forwardLabel0;

  Optional<Label> get label1 =>
      parentEdge.forwardLabel1.transform((label) {
        return isBackward ? label.flipped : label;
      });

  /**
   * Sets the label for both directed edges on an edge.
   * If `this` is backward and the label is planar, the
   * edge will be flipped before setting it on the parent
   */
  void set label0(Label label) {
    if (isBackward) {
      parentEdge.forwardLabel0 = label.flipped;
    } else {
      parentEdge.forwardLabel0 = label;
    }
  }

  void set label1(Optional<Label> label) {
    if (isBackward) {
      parentEdge.forwardLabel1 = label.transform((l) => l.flipped);
    } else {
      parentEdge.forwardLabel1 = label;
    }
  }

  int get _quadrant => directionVector.quadrant;

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
  double get angle => directionVector.angle;

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
                 de.directionVector,
                 directionVector.end);
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