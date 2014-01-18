part of geomgraph.node;

/**
 * A [NodeMap] is a map of [Coordinate]s to [Node]s,
 * ordered by the default, lexicographic ordering 
 * on coordinates.
 */
class NodeMap extends SplayTreeMap<Coordinate,Node> {
  final NodeFactory factory;
  
  NodeMap(NodeFactory this.factory) : super((c1,c2) => c1.compareTo(c2));
  
  Node addNodeAtCoordinate(Coordinate c) {
    putIfAbsent(c, () => factory(c));
    return this[c];
  }
  Node addNode(Node n) {
    putIfAbsent(n.coordinate, () => n);
    return this[n];
  }
  
  Iterable<Node> get nodes => super.values;
  Iterable<Node> get boundaryNodes =>
      super.values.where((n) => n.label0.onLocation == loc.BOUNDARY);
}