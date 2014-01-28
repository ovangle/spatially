//This file is part of Spatially.
//
//    Spatially is free software: you can redistribute it and/or modify
//    it under the terms of the GNU Lesser General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    Spatially is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU Lesser General Public License for more details.
//
//    You should have received a copy of the GNU Lesser General Public License
//    along with Spatially.  If not, see <http://www.gnu.org/licenses/>.


part of spatially.base.graph;

abstract class GraphLabel<T extends GraphLabel<T>> {}

abstract class GraphEdgeLabel<E extends GraphEdgeLabel>
extends GraphLabel<GraphEdgeLabel> {

  /**
   * Represents an edge label of a directed edge which is travelling in
   * the reverse direction (from the [:endNode:] of the edge it is attached to
   * to the [:startNode:].
   */
  GraphEdgeLabel<E> get reversed;

  /**
   * Merges two [GraphEdgeLabel]s together to form a new label.
   * This is called when adding an edge to the graph when an existing edge
   * already exists between the start and end nodes of the edge.
   *
   * A [Graph] can only possess one edge between any two nodes, so this method is to
   * provide a method of multiplexing edges. If the multiplicity of edges
   * is not important, then the method should return `this`.
   */
  GraphEdgeLabel<E> merge(GraphEdgeLabel<E> label);

}

abstract class GraphNodeLabel<N extends GraphNodeLabel>
extends GraphLabel<GraphNodeLabel> {

}