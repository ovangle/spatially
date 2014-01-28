part of spatially.base.graph;

class GraphNode<N extends GraphNodeLabel> {
  final Graph<N,dynamic> graph;
  final GraphNodeLabel<N> label;

  Set<GraphEdge> _outgoingEdges;
  Set<GraphEdge> _incomingEdges;

  GraphNode(Graph<N,dynamic> this.graph, GraphNodeLabel<N> this.label) :
    _outgoingEdges = new Set(),
    _incomingEdges = new Set();

  UnmodifiableSetView<GraphEdge> get outgoingEdges => new UnmodifiableSetView(_outgoingEdges);
  UnmodifiableSetView<GraphEdge> get incomingEdges => new UnmodifiableSetView(_incomingEdges);

  UnmodifiableSetView<GraphEdge> get terminatingEdges =>
      new UnmodifiableSetView(_outgoingEdges.union(_incomingEdges));

  /**
   * Returns all edges which run between `this` and [node]
   */
  GraphEdge connection(GraphNode node) {
    var commonEdges = terminatingEdges.intersection(node.terminatingEdges);
    if (commonEdges.isEmpty)
      return null;
    return commonEdges.single;
  }

  bool operator ==(Object other) =>
      other is GraphNode<N> && other.label == label;

  int get hashCode => label.hashCode;

  String toString() => "node: $label";

}