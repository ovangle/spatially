part of geomgraph._base;

/**
 * A [Label] indicates the topological relationship
 * between a component of a geometry graph to a given
 * [Geometry]
 * 
 * A label can be applied to any [Node] or [Edge] of
 * the graph. The label contains one or more elements, depending
 * on whether the node or edge occurs in one or both of the
 * input geometries
 * 
 * Attributes have a value from the set 
 * -- [loc.INTERIOR]
 * -- [loc.EXTERIOR]
 * -- [loc.BOUNDARY]
 * 
 * For each node, the attributes
 */
abstract class Label {
  
  /**
   * The location of the represented geometry component
   * in the first input geometry
   */
  final TopologyLocation geom1Location;
  /**
   * The location of the represented geometry component
   * in the second input geometry
   */
  final TopologyLocation geom2Location;
  
  Label(TopologyLocation this.geom1Location, 
        TopologyLocation this.geom2Location);
  
  /**
   * Is either of the [TopologyLocations] represented
   * by this [Label] an area?
   */
  bool get isArea => geom1Location.isArea
                  || geom2Location.isArea;
  
  /**
   * Is either of the [TopologyLocation]s represented
   * by this [Label] a line?
   */
  bool get isLine => geom1Location.isLine
                  || geom2Location.isLine;
  
  String toString() =>
      "LABEL(1: $geom1Location, 2: $geom2Location)";
  
}