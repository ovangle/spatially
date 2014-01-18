part of spatially.base.graph;

class GraphNode<N> {
  Graph<N, dynamic> graph;
  Label<N> label;

  GraphNode(Graph<N,dynamic> graph, Label<N> this.label);

  Set<DirectedEdge> get incomingEdges {
    Set incomingEdges = new Set();
    incomingEdges.addAll(graph.forwardEdges.where((e) => e.endNode == this));
    incomingEdges.addAll(graph.backwardEdges.where((e) => e.endNode == this));
    return incomingEdges;
  }

  Set<DirectedEdge> get outgoingEdges {
    Set outgoingEdges = new Set();
    outgoingEdges.addAll(graph.forwardEdges.where((e) => e.startNode == this));
    outgoingEdges.addAll(graph.backwardEdges.where((e) => e.startNode == this));
    return outgoingEdges;
  }

  Set<GraphEdge> get terminatingEdges =>
      graph.edges.where((e) => e.terminatingNodes.contains(this)).toSet();

  bool operator ==(Object other) {
    if (other is GraphNode<N>) {
      return other.label == label;
    }
    return false;
  }

  int get hashCode => label.hashCode;


}