library test_redblack_tree;

import 'package:unittest/unittest.dart';

import '../../lib/src/algorithms/bentley_ottmann.dart';

void main() {
  //testRotateLeft();
  //testRotateRight();
  //testRotateInverse();
  testInsert();
}
/*
void testRotateLeft() {
  final root      = new TreeNode(5);

  TreeNode left   = new TreeNode(3);
  left.childLeft  = new TreeNode(1);
  left.childRight = new TreeNode(4);
  root.childLeft = left;
  
  TreeNode right  = new TreeNode(8);
  right.childLeft = new TreeNode(7);
  right.childRight = new TreeNode(9);
  root.childRight = right;
  
  final rootCopy  = root;
  
  final expectedOrder = root.inOrderTraversal();
  root.rotateLeft();
  
  test("Rotating left preserves order",
      () => expect(root.parent.inOrderTraversal(),
                   equals(expectedOrder)));
  test("Rotating left makes left child the new root",
      () => expect(root.parent.data, equals(3)));
  
}

void testRotateRight() {
  final root      = new TreeNode(5);

  TreeNode left   = new TreeNode(3);
  left.childLeft  = new TreeNode(1);
  left.childRight = new TreeNode(4);
  root.childLeft = left;
  
  TreeNode right  = new TreeNode(8);
  right.childLeft = new TreeNode(7);
  right.childRight = new TreeNode(9);
  root.childRight = right;
  
  final rootCopy  = root;
  
  final expectedOrder = root.inOrderTraversal();
  root.rotateRight();
  
  test("Rotating right preserves order",
      () => expect(root.parent.inOrderTraversal(),
                   equals(expectedOrder)));
  test("Rotating right makes left child the new root",
      () => expect(root.parent.data, equals(8)));
  
}

testRotateInverse() {
  final root0     = new TreeNode(10);
  final root      = new TreeNode(5);

  TreeNode left   = new TreeNode(3);
  left.childLeft  = new TreeNode(1);
  left.childRight = new TreeNode(4);
  root.childLeft = left;
  
  TreeNode right  = new TreeNode(8);
  right.childLeft = new TreeNode(7);
  right.childRight = new TreeNode(9);
  root.childRight = right;
  
  final root0Copy = root0;
  
  root0.childLeft = root;
  
  (root0.childLeft as TreeNode).rotateRight();
  (root0.childLeft as TreeNode).rotateLeft();
  
  test("Rotate left is inverse of rotate right",
      () => expect(root0, equals(root0Copy))); 
}
*/


void testInsert() {
  RedBlackTree tree = new RedBlackTree<int>();
  var testData = [100, 40, 58, 88, 99, 123, 1, 23, 4, 52, 3, 11, 44, 51];
  for (var data in testData) {
    tree.insert(data);
    print(tree.root);
  }
  testRootIsBlack("Insert", tree.root);
  testRedNodeChildren("Insert", tree.root);
  testEqualPaths("Insert", tree.root);
  final sortedTestData = testData;
  sortedTestData.sort();
  test("test_redblacktree: Insert: tree is sorted",
      () => expect(tree.root.inOrderTraversal(),
                   equals(sortedTestData)));
}

void testRemove() {
  RedBlackTree<int> tree = new RedBlackTree();
  var testData = [47, 399, 12, 1, 48, 22, 23, 24, 59, 33, 34, 589, 11, 31, 88];
  for (var data in testData) {
    tree.insert(data);
  }
  final expectTree = tree.root;
  tree.remove(49);
  test("test_redblackTree: Remove: Didn't remove anything", 
       () => expect(tree.root, equals(expectTree)));
  
  var saveTree = tree.root;
  var removeNodes = [34, 11, 48, 22, 59, 88];
  for (var data in removeNodes) {
    saveTree.remove(data);
  }
  testRootIsBlack("Remove", saveTree.root);
  testRedNodeChildren("Remove", saveTree.root);
  testEqualPaths("Remove", saveTree.root);
  var remainingNodes = testData.removeWhere((e) => removeNodes.contains(e));
  remainingNodes.sort();
  test("test_redblacktree: Remove: tree is sorted",
      () => expect(saveTree.root.inOrderTraversal(),
                  equals(remainingNodes)));
}

/**
 * We want to support swapping the position of items in the tree.
 * This is not part of the redblack_tree implementation but is useful for the bentley_ottman
 * algorithm. 
 */
void testSwap() {
  
}

Matcher isBlack = isFalse;
Matcher isRed = isTrue;
/**
 * The properties of a redblack tree need to be preserved by insert/remove/swap.
 */

/**
 * The root must always be black
 */
void testRootIsBlack(String method, RedBlackTree t) {
  test("test_redblacktree: $method: Root of tree is black", () => expect(t.root.colour, isBlack));
}
/**
 * Every red node must have two black children
 */
void testRedNodeChildren(String method, RedBlackTree t) {
  var redChildren = [];
  collectRedChildren(TreeNode t) {
    if (t.childLeft is TreeNode) {
      var left = t.childLeft as TreeNode;
      if (left.colour == RED) {
        redChildren.addAll([left.childLeft, left.childRight]);
      }
      collectRedChildren(left);
    }
    if (t.childRight is TreeNode) {
      var right = t.childRight as TreeNode;
      if (right.colour == RED) {
        redChildren.addAll([right.childLeft, right.childRight]);
      }
      collectRedChildren(right);
    }
  }
  collectRedChildren(t.root);
  test("test_redblacktree: $method: Every red node has two black children",
      () => expect(redChildren, 
                   everyElement(predicate((e) => !e.colour, "is black" ))));
}

/**
 * Every redblack tree must have an equal number of black nodes
 * between teh root and any leaf
 */
void testEqualPaths(String method, RedBlackTree t) {
  List<List> collectPaths(TreeNode t) {
    var leftPaths, rightPaths;
    if (t.childLeft is TreeNode) {
      leftPaths = collectPaths(t.childLeft);
    } else {
      leftPaths = [[t.childLeft]];
    }
    if (t.childRight is TreeNode) {
      rightPaths = collectPaths(t.childRight);
    } else {
      rightPaths = [[t.childRight]];
    }
    
    if (t.colour == BLACK) {
      for (var p in leftPaths) { p.add(t); }
      for (var p in rightPaths) { p.add(t); }
    }
    var paths = [leftPaths, rightPaths].expand((p) => p).toList();
    return paths;
  }
  var blackPaths = collectPaths(t.root);
  var len = blackPaths[0].length;
  test("test_redblacktree: $method: Every path from root to leaf has the same length",
      () => expect(blackPaths, everyElement(hasLength(equals(len)))));
}

