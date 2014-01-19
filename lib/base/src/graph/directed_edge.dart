part of spatially.base.graph;

class DirectedEdge<E> {
  GraphEdge<E> _edge;
  GraphEdge<E> get edge => _edge;
  final Label<E> label;
  GraphNode _startNode;
  GraphNode get startNode => _startNode;
  GraphNode _endNode;
  GraphNode get endNode => _endNode;

  DirectedEdge(this._edge, this.label, this._startNode, this._endNode);

  bool get isForward =>
      new Optional.of(this) == edge.forwardEdge;
  bool get isBackward =>
      new Optional.of(this) == edge.backwardEdge;

  void _unlink() {
    _edge = null;
    _startNode = null;
    _endNode = null;
  }

  /**
   * Returns the complement edge in the parent, if it
   * is present.
   */
  Optional<DirectedEdge<E>> get complement =>
      isForward ? edge.backwardEdge : edge.forwardEdge;

  bool operator ==(Object other) {
    if (other is DirectedEdge<E>) {
      return label == other.label;
    }
    return false;
  }

  int get hashCode => label.hashCode;

  String toString() => label.toString();
}