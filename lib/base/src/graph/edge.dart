part of spatially.base.graph;

class GraphEdge<E> {
  final Graph<dynamic, E> graph;
  Optional<DirectedEdge<E>> _forwardEdge;
  Optional<DirectedEdge<E>> get forwardEdge => _forwardEdge;
  Optional<DirectedEdge<E>> _backwardEdge;
  Optional<DirectedEdge<E>> get backwardEdge => _backwardEdge;

  GraphEdge(this.graph,
       Optional<Label<E>> forwardLabel,
       Optional<Label<E>> backwardLabel,
       GraphNode startNode,
       GraphNode endNode) {
    assert(forwardLabel.isPresent || backwardLabel.isPresent);
    _forwardEdge = forwardLabel.transform((lbl) => new DirectedEdge<E>(this, lbl, startNode, endNode));
    _backwardEdge = backwardLabel.transform((lbl) => new DirectedEdge<E>(this, lbl, endNode, startNode));
  }

  bool get isForward => forwardEdge.isPresent && !backwardEdge.isPresent;
  bool get isBackward => backwardEdge.isPresent && !forwardEdge.isPresent;

  bool get isUndirected => forwardEdge.isPresent && backwardEdge.isPresent;

  Set<GraphNode> get terminatingNodes {
    var terminatingNodes = new Set<GraphNode>();
    _forwardEdge.ifPresent((fwd) {
      terminatingNodes.add(fwd.startNode);
      terminatingNodes.add(fwd.endNode);
    });
    _backwardEdge.ifPresent((bwd) {
      terminatingNodes.add(bwd.startNode);
      terminatingNodes.add(bwd.endNode);
    });
    assert(terminatingNodes.length == 2);
    return terminatingNodes;
  }


  Optional<Label<E>> get forwardLabel =>
      forwardEdge.transform((e) => e.label);
  Optional<Label<E>> get backwardLabel =>
      backwardEdge.transform((e) => e.label);

  bool _removeForward() {
    _forwardEdge = new Optional.absent();
    _backwardEdge.ifAbsent(() {
      graph._removeEdge(this);
    });
    return true;
  }

  bool _removeBackward() {
    _backwardEdge = new Optional.absent();
    _forwardEdge.ifAbsent(() {
      graph._removeEdge(this);
    });
    return true;
  }

  /**
   * Two [GraphEdge]s are considered equal if they are equal
   * modulo the directions of their edges.
   */
  bool operator ==(Object other) {
    if (other is GraphEdge<E>) {
      if (forwardEdge == other.forwardEdge) {
        return backwardEdge == other.backwardEdge;
      }
      if (forwardEdge == other.backwardEdge) {
        return backwardEdge == other.forwardEdge;
      }
    }
    return false;
  }

  /**
   * The hashCode returned by an edge is directionally symetric
   */
  int get hashCode =>
      forwardEdge.hashCode + backwardEdge.hashCode;
}