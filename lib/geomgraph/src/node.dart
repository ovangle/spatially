part of geomgraph._base;

class Node extends GraphComponent {
  //Only non-null if node is precise.
  Coordinate _coordinate;
  
  EdgeEndStar _edges;
  
  Node(Label label) : super(label);
  
  Coordinate get coordinate => _coordinate;
  EdgeEndStar get edges => _edges;
  
  /**
   * An an edge to the sorted edges at this [Node].
   */
  void add(EdgeEnd e) {
    _edges.add(e);
  }
  
}