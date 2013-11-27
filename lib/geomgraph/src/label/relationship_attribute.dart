part of geomgraph.label;

/**
 * Represents a relationship between a graph component
 * and a single geometry.
 * 
 * If the graph component, represents an area of the 
 * geometry, then the attribute will have
 */
class RelationshipAttribute {
  final int on;
  final int left;
  final int right;
  final bool isArea;
  
  bool get isLine => !isArea;
  
  RelationshipAttribute._(int this.on,
                          int this.left,
                          int this.right, 
                          bool this.isArea);
  
  RelationshipAttribute.area({int on, int left, int right}) :
    this._(on, left, right, true);
  RelationshipAttribute.line({int on}) :
    this(on, loc.NONE, loc.NONE, false);
  RelationshipAttribute.node({int on}) :
    this(on, loc.NONE, loc.NONE, false);
  
  bool get everyNone => [on, left, right].every((l) => l == loc.NONE);
  bool get anyNone   => [on, left, right].any((l) => l == loc.NONE);
  
  bool equalLeft(RelationshipAttribute relAttr) =>
      left == relAttr.left;
  bool equalRight(RelationshipAttribute relAttr) =>
      right == relAttr.right;
  bool equalOn(RelationshipAttribute relAttr) =>
      on == relAttr.on;
  
  /**
   * A [RelationshipAttribute] with the [left] and [right]
   * sides of the relationship reversed.
   */
  RelationshipAttribute get flipped =>
    new RelationshipAttribute._( on, right, left, isArea);
  
  RelationshipAttribute merge(RelationshipAttribute other) {
    return new RelationshipAttribute._(
        (on == loc.NONE) ? other.on : on,
        (left == loc.NONE) ? other.left : left,
        (right == loc.NONE) ? other.right : right,
        (other.isArea));
  }
  
  String toString() {
    if (isArea) return "<LEFT: $left, ON: $on, RIGHT: $right>";
    return "<ON: $on>";
  }
}
