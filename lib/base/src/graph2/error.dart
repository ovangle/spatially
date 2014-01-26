part of spatially.base.graph;

class GraphError extends StateError {
  GraphError(msg) : super(msg);

  String toString() => "GraphError(${this.message})";
}