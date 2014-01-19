library spatially.base.graph_tests;

import 'package:unittest/unittest.dart';
import 'package:quiver/core.dart';
import 'package:spatially/base/graph.dart';

class MockLabel implements Label {
  final int labelId;
  MockLabel(this.labelId);

  bool operator ==(Object other) => (other is MockLabel) && other.labelId == labelId;

  int get hashCode => labelId;
  String toString() => "Label($labelId)";
}

class MockGraph<T,U> extends Graph<T,U> {

  NodeFactory<T,U> get nodeFactory => _nodeFactory;
  GraphNode<T> _nodeFactory(MockGraph g, Label<T> nodeLabel) =>
      new GraphNode(g, nodeLabel);

  EdgeFactory<T,U> get edgeFactory => _edgeFactory;
  GraphEdge<U> _edgeFactory(
      MockGraph g,
      Optional<Label<U>> fwdLabel,
      Optional<Label<U>> bwdLabel,
      GraphNode<T> startNode,
      GraphNode<T> endNode) {
    return new GraphEdge(g, fwdLabel, bwdLabel, startNode, endNode);
  }
}

main() {
  group("graph", () {
    test("should be able to add a node to the graph", () {
      Graph graph = new MockGraph<int,int>();
      var node = graph.addNode(new MockLabel(1));
      expect(graph.nodes.map((n) => n.label), [new MockLabel(1)]);
      expect(node.label, new MockLabel(1));
      expect(node.graph, graph);
    });

    test("should be able to fetch a node by its label", () {
      Graph graph = new MockGraph<int,int>();
      graph.addNode(new MockLabel(1));
      expect(graph.nodeByLabel(new MockLabel(1)).transform((n) => n.label),
             new Optional.of(new MockLabel(1)));
      expect(graph.nodeByLabel(new MockLabel(2)).isPresent, isFalse);
    });

    test("should be able to add a forward edge to a graph", () {
      Graph graph = new MockGraph<int,int>();
      var startNode = graph.addNode(new MockLabel(1));
      var endNode = graph.addNode(new MockLabel(2));

      GraphEdge e = graph.addForwardEdge(new MockLabel(4), startNode, endNode);

      expect(e.graph, graph);

      expect(graph.forwardEdges.map((e) => e.label), [new MockLabel(4)]);
      expect(graph.backwardEdges, isEmpty);

      expect(e.forwardEdge.transform((e) => e.label), new Optional.of(new MockLabel(4)));
      expect(e.backwardEdge.isPresent, isFalse);
      expect(e.forwardEdge.transform((e) => e.startNode.label), new Optional.of(new MockLabel(1)));
      expect(e.forwardEdge.transform((e) => e.endNode.label), new Optional.of(new MockLabel(2)));
    });

    test("should be able to add a backward directed edge to a graph", () {
      Graph graph = new MockGraph<int,int>();
      var startNode = graph.addNode(new MockLabel(1));
      var endNode = graph.addNode(new MockLabel(2));

      GraphEdge e = graph.addBackwardEdge(new MockLabel(4), startNode, endNode);

      expect(e.graph, graph);

      expect(graph.backwardEdges.map((e) => e.label), [new MockLabel(4)]);
      expect(graph.forwardEdges, isEmpty);

      expect(e.backwardEdge.transform((e) => e.label), new Optional.of(new MockLabel(4)));
      expect(e.forwardEdge.isPresent, false);

      expect(e.backwardEdge.transform((e) => e.startNode.label), new Optional.of(new MockLabel(2)));
      expect(e.backwardEdge.transform((e) => e.endNode.label), new Optional.of(new MockLabel(1)));

      GraphEdge e1 = graph.addBackwardEdge(new MockLabel(4), startNode, endNode);
      expect(identical(e,e1), isTrue);

      GraphEdge e2 = graph.addForwardEdge(new MockLabel(4), startNode, endNode);
      expect(identical(e, e2), isFalse);
    });

    test("should be able to add an undirected edge to a graph", () {
      Graph graph = new MockGraph<int,int>();
      var startNode = graph.addNode(new MockLabel(1));
      var endNode = graph.addNode(new MockLabel(2));
      GraphEdge e = graph.addUndirectedEdge(new MockLabel(4), new MockLabel(5), startNode, endNode);

      expect(e.forwardEdge.transform((e) => e.label), new Optional.of(new MockLabel(4)));
      expect(e.backwardEdge.transform((e) => e.label), new Optional.of(new MockLabel(5)));

      expect(e.forwardEdge.transform((e) => e.startNode), new Optional.of(startNode));
      expect(e.backwardEdge.transform((e) => e.startNode), new Optional.of(endNode));

      expect(e.forwardEdge.transform((e) => e.endNode), new Optional.of(endNode));
      expect(e.backwardEdge.transform((e) => e.endNode), new Optional.of(startNode));

      GraphEdge e1 = graph.addForwardEdge(new MockLabel(4), startNode, endNode);
      expect(identical(e, e1), isTrue);
      GraphEdge e2 = graph.addBackwardEdge(new MockLabel(4), startNode, endNode);
      expect(identical(e, e2), isFalse);
    });

    test("should be able to get the outgoing edges of a node", () {
      Graph graph = new MockGraph<int,int>();
      var node1 = graph.addNode(new MockLabel(1));
      var node2 = graph.addNode(new MockLabel(3));
      var node3 = graph.addNode(new MockLabel(4));


      graph.addForwardEdge(new MockLabel(5), node2, node3);

      expect(node1.outgoingEdges, isEmpty);
      expect(node2.outgoingEdges.map((e) => e.label), [new MockLabel(5)]);
      expect(node3.outgoingEdges, isEmpty);

    });

    test("should be able to get the incoming edges of a node", () {

      Graph graph = new MockGraph<int,int>();
      var node1 = graph.addNode(new MockLabel(1));
      var node2 = graph.addNode(new MockLabel(3));
      var node3 = graph.addNode(new MockLabel(4));


      graph.addBackwardEdge(new MockLabel(5), node2, node3);

      expect(node1.incomingEdges, isEmpty);
      expect(node2.incomingEdges.map((e) => e.label), [new MockLabel(5)]);
      expect(node3.incomingEdges, isEmpty);
    });

    test("should be able to get the terminating edges of a node", () {

      Graph graph = new MockGraph<int,int>();
      var node1 = graph.addNode(new MockLabel(1));
      var node2 = graph.addNode(new MockLabel(3));
      var node3 = graph.addNode(new MockLabel(4));

      graph.addForwardEdge(new MockLabel(5), node2, node3);

      expect(node1.terminatingEdges, isEmpty);
      expect(node2.terminatingEdges, isNot(isEmpty));
      expect(node3.terminatingEdges, isNot(isEmpty));
    });

    test("should be able to remove a node from the graph", () {
      Graph graph = new MockGraph<int,int>();
      var node1 = graph.addNode(new MockLabel(1));
      var node2 = graph.addNode(new MockLabel(2));
      var node3 = graph.addNode(new MockLabel(3));

      graph.addForwardEdge(new MockLabel(5), node2, node3);
      graph.removeNode(new MockLabel(1));
      expect(graph.nodeByLabel(new MockLabel(1)).isPresent, false);

      expect(node1.graph, isNull,
             reason: "Removed nodes are unlinked from the graph");

      expect(() => graph.removeNode(new MockLabel(3)), throws,
             reason: "Node has outgoing edges");
    });

    test("should be able to remove a forward directed edge", () {
      Graph graph = new MockGraph<int,int>();
      var startNode = graph.addNode(new MockLabel(1));
      var endNode = graph.addNode(new MockLabel(2));

      var edge = graph.addForwardEdge(new MockLabel(4), startNode, endNode);
      expect(graph.removeForwardEdge(new MockLabel(4)), isTrue);
      expect(graph.removeForwardEdge(new MockLabel(4)), isFalse);

      expect(graph.edges.every((e) => e.forwardEdge.isPresent || e.backwardEdge.isPresent), isTrue,
             reason: "No orphaned edges");

      expect(edge.graph, isNull, reason: "unlinked from graph");
    });

    test("should be able to remove a backward directed edge", () {
      Graph graph = new MockGraph<int,int>();
      var startNode = graph.addNode(new MockLabel(1));
      var endNode = graph.addNode(new MockLabel(2));

      var edge = graph.addBackwardEdge(new MockLabel(4), startNode, endNode);
      expect(graph.removeBackwardEdge(new MockLabel(4)), isTrue);
      expect(graph.removeBackwardEdge(new MockLabel(4)), isFalse);

      expect(edge.graph, isNull, reason: "unlinked from graph");
      expect(graph.edges.every((e) => e.forwardEdge.isPresent || e.backwardEdge.isPresent), isTrue,
          reason: "No orphaned edges");
    });

    test("should be able to remove a single direction of an undirected edge", () {
      Graph graph = new MockGraph<int,int>();
      var startNode = graph.addNode(new MockLabel(1));
      var endNode = graph.addNode(new MockLabel(2));

      var edge = graph.addUndirectedEdge(new MockLabel(4), new MockLabel(5), startNode, endNode);
      expect(graph.removeForwardEdge(new MockLabel(4)), isTrue);
      expect(graph.backwardEdges.map((e) => e.label), [new MockLabel(5)]);

      expect(edge.graph, isNotNull, reason: "not yet unlinked from graph");
    });
  });
}

