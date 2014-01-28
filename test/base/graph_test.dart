library spatially.base.graph.graph_test;

import 'package:unittest/unittest.dart';

import 'package:spatially/base/graph.dart';


class MockNodeLabel implements GraphNodeLabel<MockNodeLabel> {
  int id;

  MockNodeLabel(int this.id);

  bool operator ==(Object other) =>
      other is MockNodeLabel && id == other.id;
  int get hashCode => id;

  String toString() => "$id";
}

class MockEdgeLabel implements GraphEdgeLabel<MockEdgeLabel> {
  int id1;
  int id2;
  bool isMerged = false;

  MockEdgeLabel(this.id1, this.id2);

  MockEdgeLabel get reversed => new MockEdgeLabel(id2, id1);

  MockEdgeLabel merge(MockEdgeLabel label) {
    isMerged = true;
    return this;
  }

  bool operator ==(Object other) =>
      other is MockEdgeLabel && id1 == other.id1 && id2 == other.id2;

  int get hashCode =>
      17 * id1 + id2;

  String toString() => "$id1 -> $id2";

}

void main() {
  group("graph", () {
    test("should be able to add a node to the graph", () {
      Graph<MockNodeLabel,MockEdgeLabel> graph = new Graph();
      var n1 = graph.addNode(new MockNodeLabel(1));
      expect(n1.label, new MockNodeLabel(1));
      expect(graph.nodes, [n1]);

      var n2 = graph.addNode(new MockNodeLabel(2));
      expect(graph.nodes, unorderedEquals([n1, n2]));
    });

    //TODO: remove node.

    Graph<MockNodeLabel,MockEdgeLabel> graph = new Graph();
    var n1 = graph.addNode(new MockNodeLabel(1));
    var n2 = graph.addNode(new MockNodeLabel(2));
    var n3 = graph.addNode(new MockNodeLabel(3));

    test("should be able to add a directed edge to the graph", () {
      var e12 = graph.addDirectedEdge(new MockEdgeLabel(1,2), n1, n2);
      expect(e12.startNode, n1);
      expect(e12.endNode, n2);
      expect(e12.label, new MockEdgeLabel(1,2));
      expect(graph.edges, [e12]);
      expect(n1.outgoingEdges, [e12], reason: "start outgoing edges");
      expect(n1.incomingEdges, [], reason: "start incoming edges");
      expect(n2.incomingEdges, [e12], reason: "end incoming edges");
      expect(n2.outgoingEdges, [], reason: "end outgoing edges");
    });

    test("should throw if trying to add a directed edge with the same label but different start and end nodes", () {
      expect(() => graph.addDirectedEdge(new MockEdgeLabel(1,2), n1, n2), returnsNormally, reason: "edge already in graph");
      expect(() => graph.addDirectedEdge(new MockEdgeLabel(1,2), n1, n3), throws, reason: "bad end");
      expect(() => graph.addDirectedEdge(new MockEdgeLabel(1,2), n3, n1), throws, reason: "bad start");
      expect(() => graph.addDirectedEdge(new MockEdgeLabel(2,1), n2, n1), throws, reason: "reverse label");
    });

    test("should merge the edges when adding a label between the same start and end nodes", () {
      var e = graph.addDirectedEdge(new MockEdgeLabel(2,4), n1, n2);
      expect(e.label, new MockEdgeLabel(1,2));
      expect(e.label.isMerged, isTrue);
      expect(graph.edges, [e]);
    });

    test("should be able to remove an edge from the graph", () {
      var r = graph.removeEdge(graph.edges.single.label);
      expect(r.label, new MockEdgeLabel(1,2));
      expect(graph.edges, []);
      expect(n1.terminatingEdges, []);
      expect(n2.terminatingEdges, []);

      var r2 = graph.removeEdge(new MockEdgeLabel(2,3));
      expect(r2, isNull, reason: "no existing edge with label");
    });

    test("should be able to add an undirected edge to the graph", () {
      var e12 = graph.addUndirectedEdge(new MockEdgeLabel(1,2), n1, n2);
      expect(e12.label, new MockEdgeLabel(1,2));
      expect(e12.terminatingNodes, unorderedEquals([n1,n2]));
      expect(e12.isDirected, isFalse);
      expect(n1.outgoingEdges, [e12], reason: "start outgoing edges");
      expect(n1.incomingEdges, [e12], reason: "start incoming edges");
      expect(n2.incomingEdges, [e12], reason: "end outgoing edges");
      expect(n2.outgoingEdges, [e12], reason: "end incoming edges");
    });

    test("should throw when trying to add an edge with the same label but different terminating nodes", () {
      expect(() => graph.addUndirectedEdge(new MockEdgeLabel(1,2), n1, n2), returnsNormally, reason: "same undirected edge");
      expect(() => graph.addUndirectedEdge(new MockEdgeLabel(2,1), n2, n1), returnsNormally, reason: "reverse undirected edge");
      expect(() => graph.addUndirectedEdge(new MockEdgeLabel(1,2), n1, n3), throws, reason: "bad start");
      expect(() => graph.addUndirectedEdge(new MockEdgeLabel(1,2), n3, n2), throws, reason: "bad start");
    });

    test("adding an edge between the same start and end nodes should merge the nodes", () {
      var e23 = graph.addUndirectedEdge(new MockEdgeLabel(2,3), n2, n3);
      var e46 = graph.addUndirectedEdge(new MockEdgeLabel(4,6), n2, n3);
      expect(e46.label.isMerged, isTrue);
      expect(graph.edges.map((e) => e.label),
             unorderedEquals([new MockEdgeLabel(1,2),
                              new MockEdgeLabel(2,3)
                             ]));
    });

    test("should be able to replace an undirected edge by a directed edge", () {
      var e23u = graph.edgeByLabel(new MockEdgeLabel(2,3));
      expect(e23u.isDirected, isFalse);
      var e23 = graph.replaceEdge(e23u.label, e23u.asDirectedEdge(asForward: true));
      expect(e23.label, new MockEdgeLabel(2,3));
      expect(e23.isDirected, isTrue);
      expect(graph.edges.map((e) => e.label),
             unorderedEquals([new MockEdgeLabel(2,3),
                              new MockEdgeLabel(1,2)]));
      graph.removeEdge(e23.label);

      //Replace by backward edge.
      var e32u = graph.addUndirectedEdge(new MockEdgeLabel(3,2), n3, n2);
      e23 = graph.replaceEdge(e32u.label, e32u.asDirectedEdge(asForward: false));
      expect(e23.label, new MockEdgeLabel(2,3));
      expect(e23.startNode, n2);
      expect(e23.endNode, n3);
    });
  });


}