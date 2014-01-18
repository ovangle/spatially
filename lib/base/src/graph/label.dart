part of spatially.base.graph;

class Label<T> {

  /**
   * Labels need to implement `==` operator
   */
  bool operator ==(Object other) =>
    throw new UnimplementedError("Label.==");

  int get hashCode =>
      throw new UnimplementedError("Label.hashCode");

}