part of geomgraph._base;

/**
  * A [TopologyLocation] is a labelling of a [GraphComponent]s
  * topological relationship to a single [Geometry].s
  */
abstract class TopologyLocation {
  TopologyLocation();
  
  int get on;
  
  /**
   * This [Topologylocation] represents a linear location of 
   * the represented [Geometry]
   * 
   * Equivalent to `is NodeLocation`
   */
  bool get isLine;
  
  /**
   * This [TopologyLocation] represents an area location of
   * the represented [Geometry]
   * 
   * Equivalent to `is EdgeLocation`
   */
  bool get isArea;
}

class NodeLocation extends TopologyLocation {
  /**
   * Specifies how points on the [GraphComponent]
   * labelled with this [TopologyLocation] relate
   * to some [Geometry].
   */
  final int on;
  NodeLocation({int this.on});
  
  bool get isLine => true;
  bool get isArea => false;
  
  bool operator ==(Object other) => (other is NodeLocation)
                                 && (on == other.on);
  /**
   * Shouldn't be using this as a key
   */
  int get hashCode => on.hashCode;
  
  String toString() =>
      "NODE_LOC"
      "<o: ${loc.toLocationSymbol(on)}>";
 
}

class EdgeLocation extends TopologyLocation {
  /**
   * Specifies how points on the [GraphComponent]
   * labelled with this [TopologyLocation] relate
   * to some [Geometry].
   */
  final int on;
  /**
   * Specifies how points to the left of the [GraphComponent]
   * labelled with this [TopologyLocation] relate
   * to some [Geometry];
   */
  final int left;
  /**
   * Specifies how points to the right of the [GraphComponent]
   * labelled with this [TopologyLocation] relate
   * to some [Geometry]
   */
  final int right;
  EdgeLocation({int this.on, int this.left, int this.right});
  
  
  Iterable<int> get locations => [on, left, right];
  
  bool get isLine => false;
  bool get isArea => true;
  
  /**
   * Returns a [TopologyLocation] with locations [:left:] and
   * [:right:] reversed, as if the [Geometry] was inverted.
   */
  TopologyLocation get flipped =>
      new EdgeLocation(on: this.on, left: this.right, right: this.left);

  
  bool operator ==(Object other) => (other is EdgeLocation)
                                 && other.on == this.on
                                 && other.left == this.left
                                 && other.right == this.right;
  
  /**
   * Shouldn't be using this as a key, but...
   */
  int get hashCode => 
      [on, left, right].fold(7.0, (h, pos) => h * 7.0 + pos);
  
  NodeLocation asLine() =>
      new NodeLocation(on: on);
  
  String toString() =>
      "EDGE_LOC"
      "<o: ${loc.toLocationSymbol(on)}, "
       "l: ${loc.toLocationSymbol(left)}, "
       "r: ${loc.toLocationSymbol(right)}>";
}