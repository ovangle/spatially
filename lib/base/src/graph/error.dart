part of spatially.base.graph;

class GraphError extends ArgumentError {
  GraphError(String msg) : super(msg);

  factory GraphError.existingEdge(
      Label label,
      GraphNode argNode,
      GraphNode existingNode,
      bool isForward,
      bool isStart) {
    var msg =
        "${isForward ? "Forward" : "Backward"} edge with label $label "
        "already exists in the graph but ${isStart ? "start" : "end"} "
        "node was $existingNode (received: $argNode)";
    return new GraphError(msg);
  }
}

void _addCheckLabels(Label label,
                     GraphNode startNode, GraphNode argStartNode,
                     GraphNode endNode, GraphNode argEndNode,
                     {bool isForward}) {

  if (startNode != argStartNode) {
    throw new GraphError.existingEdge(
        label, argStartNode, startNode, isForward, true);
  }

  if (endNode != argEndNode) {
    throw new GraphError.existingEdge(
        label, argEndNode, endNode, isForward, false);
  }

}