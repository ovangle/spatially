part of spatially.base.graph;

class DirectedEdge<E> {
  final GraphEdge<E> edge;
  final Label<E> label;
  final GraphNode startNode;
  final GraphNode endNode;

  DirectedEdge(this.edge, this.label, this.startNode, this.endNode);

  bool get isForward =>
      new Optional.of(this) == edge.forwardEdge;
  bool get isBackward =>
      new Optional.of(this) == edge.backwardEdge;

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
}