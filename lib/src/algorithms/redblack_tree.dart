part of bentley_ottman;

const bool BLACK = false;
const bool RED = true;

/**
 * A [RedBlackTree] is a self-balancing binary tree with O(log n) insertion and removal
 * of nodes.
 * 
 * The leaf nodes of a [RedBlackTree] do not contain data, 
 * 
 * A [RedBlackTree] has the following constraints:
 * 0. All nodes must be covered red or black
 * 1. The root node must be coloured black
 * 2. All leaves of the tree must be coloured black
 * 3. A node can only be coloured red if both of it's children are black.
 * 4. All paths from the root of the tree to a leaf must pass the same number of black nodes 
 * 
 * These constraints ensure that the path from the root to the furthes leaf is no more
 * than twice as long as the path to the nearest leaf.
 */
abstract class RedBlackTree<T> {
  /**
   * The parent of the current node. 
   * The parent of the root node of the tree is null.
   */
  TreeNode _parent;
  /**
   * The colour of the current node.
   */
  bool colour;
  
  Comparator<T> comparator;
  
  RedBlackTree._();
  
  factory RedBlackTree([Comparator<T> compareData]) {
    if (compareData == null) compareData = Comparable.compare;
    return new TreeNode._(null, compareData, true);
  }
  
  TreeNode get parent => _parent;
  /**
   * The root node of the tree.
   */
  TreeNode get root => (parent == null) ? this : parent.root;
  
  /**
   * The [:grandParent:] of the current node, or `null` if the parent is the [:root:] of the tree.
   */
  TreeNode get grandParent {
    if (parent == null) return null;
    return parent.parent;
  }
  
  /**
   * The [:uncle:] of a [RedBlackTree] is the sibling node of the parent of the tree
   * or `null` if the 
   */
  RedBlackTree<T> get uncle {
    if (parent == null) return null;
    return parent.sibling;
  }
  
  RedBlackTree<T> get sibling {
    if (parent == null) return null;
    return (_isLeft) ? parent.childRight : parent.childLeft;
  }
      
  /**
   * `true` if the tree is the left child of it's parent.
   * Private since fails for TreeLeaves (which all compare equal)
   */
  bool get _isLeft => this == parent.childLeft;
  
  /**
   * `true` if the tree is the right child of it's parent 
   * and the node is not the root
   */
  bool get _isRight => this == parent.childRight;
  
  /**
   * Inserts the data into the tree. Inserting data can change
   * the root node, so a reference to the root of the tree is 
   * returned.
   */
  RedBlackTree<T> insert(T data) => root.._insert(data);
  
  /**
   * Removes the data from the tree. Removing data can change
   * the root node, so a reference to the root of the tree is
   * returned.
   */
  RedBlackTree<T> remove(T data) => root.._remove(data);
  
  /**
   * Returns the node in the tree with the given data.
   * or `null` if the data wasn't in the tree
   */
  TreeNode<T> find(T data) {
    RedBlackTree<T> found = root._find(data);
    return (found is! TreeLeaf) ? found : null;
  }
  
  
  String __str({indent: 0});
}

class TreeNode<T> extends RedBlackTree<T> {
  bool colour;
  RedBlackTree<T> _childLeft;
  RedBlackTree<T> _childRight;
  
  Comparator<T> comparator;
  bool isInit;
  T data;
  
  RedBlackTree<T>
    get childLeft => _childLeft;
    set childLeft(RedBlackTree<T> value) {
      _childLeft = value;
      _childLeft._parent = this;
    }
    
  RedBlackTree<T>
   get childRight => _childRight;
   set childRight(RedBlackTree<T> value) {
      _childRight = value;
      _childRight._parent = this;
   }
  
  TreeNode._(T this.data, Comparator<T> this.comparator, [bool isInit]) : super._() {
    this.isInit = isInit != null && isInit;
    colour = (this.isInit ? BLACK : RED);
    childLeft = new TreeLeaf._();
    childRight = new TreeLeaf._();
  }
  
  
  
  List<T> inOrderTraversal() {
    List items = new List();
    if (childLeft is TreeNode) {
      items.addAll((childLeft as TreeNode).inOrderTraversal());
    }
    items.add(data);
    if (childRight is TreeNode) {
      items.addAll((childRight as TreeNode).inOrderTraversal());
    }
    return items;
    
  }
  
  /**
   * Returns the last node before the current node according to the [:comparator:]
   */
  T lastBefore(T k) {
    if (comparator(data, k) > 0) {
      if (parent == null) {
        return data;   
      }
      return parent.lastBefore(k);
    }
    
  }
  
  /**
   * Insert data into a node.
   */
  RedBlackTree<T> _insert(T data) {
    if (isInit) {
      // The first treenode in the tree is created
      // without any data. We initialize the data the first time
      // insert is called on the node.
      this.data = data;
      isInit = false;
      return this;
    }
    final insertAt = _find(data);
    if (insertAt is TreeNode) {
      // The data is already in the tree.
      return root;
    }
    //We've found a leaf which should be replaced with the 
    //data we want to insert.
    final insertInto = insertAt.parent;
    final cmp = comparator(insertInto.data, data);
    TreeNode newNode = new TreeNode._(data, comparator);
    if (cmp < 0) insertInto.childLeft = newNode;
    if (cmp > 0) insertInto.childRight = newNode;
    newNode._repaint_insert();
    return root;
  }
    
  /**
   * Repaint the tree after an insertion.
   */
  void _repaint_insert() {
    //The colour of the node when first inserted is always red
    assert(colour == RED);
    //CASE 1: The node is the root of the tree
    //        The root must always be black, so paint it black
    if (parent == null) {
      //The root must always be black
      colour = BLACK;
      return;
    }
    //CASE 2: The parent is black
    //        In this case just return. We know our children are leaves or black
    //        subtrees, so we can add the node uninhibited to the parent.
    if (parent.colour == BLACK) {
      return;
    }
    // Since our parent is not black, we can safely assume we have a grandparent.
    
    //CASE 3: Both the parent and uncle are red
    if (parent.colour == RED && uncle.colour == RED) {
      // Analysis is drawn with Node on the right. The analysis for the other
      // case is symmetric.
      //            G(B) 
      //           /    \
      //        P(B)     U(B)
      //       /   \     
      //   1(B)    N(R)  
      //
      // The parent is invalid, since it contains both a red and a black child.
      // If we paint both the parent and uncle black, we obtain:
      //
      //            G(B) 
      //           /    \
      //        P(B)     U(B)
      //        /  \     
      //    ?(B)    N(R) 
      //
      // Since the trees were balanced before the insertion, they remain balanced
      // after the insertion.
      // This structure might be part of a larger subtree, and in this case we
      // will have imbalanced the tree by introducing an extra black node
      // (In cases 2-5 we retain the same number of black nodes in the subtree)
      // 
      // To correct this, the grandparent G can be painted red and calling 
      // _repaint_insert on the grandparent to ensure that the integrity of the
      // entire tree is ensured.
      // 
      // This is the only recursive part of the process (the rest can be completed
      // in constant time) and since we can only proceed up the tree, the most time
      // it can take is O(log n)
      parent.colour = BLACK;
      uncle.colour = BLACK;
      grandParent.colour = RED;
      // Recurse onto grandparent, because we might have repainted
      // the root
      grandParent._repaint_insert();
      return;
    }
    
    // the remaining cases are when the parent is RED and the uncle is BLACK
    // And thus the grandparent must be BLACK.
    final isLeft = _isLeft; final isRight = _isRight;
    final parentIsLeft = parent._isLeft; final parentIsRight = parent._isRight;
    
    //CASE 4: isRight and parent.isLeft
    //        or isLeft and parent.isRight.
    if ((isLeft && parentIsRight) || (isRight && parentIsLeft)) {    
      // Analysis for when the parent is on the left:
      // (right is symmetric).
      // The subtree must have been balanced before the insertion, so the subtrees
      // 1, 2 and 3 must have an identical number of black nodes, and the uncle must be the
      // head of one of those subtrees.
      // The subtrees 1, 2, and 3 must have black nodes at their roots, since P was red.
      // and contain a balanced number of black nodes.
      //
      //            G(B) 
      //           /    \
      //        P(R)     U(B)
      //       /   \     
      //   1(B)    N(R)  
      //           /  \
      //        2(B)   3(B)
      //
      // If we rotate right (on the parent), we obtain
      //
      //            G(B) 
      //           /    \
      //        N(R)     U(B) ~ ?
      //       /   \     
      //     P(R)   3(B)    
      //     /  \
      //  1(B)  2(B)
      //
      // Note that the node N is still invalid, since it contains both a red 
      // and a black child. But since the P is now on the left side of N,
      // call _repaint_insert on the parent node (which will match case 5), 
      // correcting the tree.
      if (isRight) {
        final p = parent;
        p.rotateRight();
        p._repaint_insert();
      }
      if (isLeft) {
        final p = parent;
        p.rotateLeft();
        p._repaint_insert();
      }
      return;
    }
    //CASE 5: parent isLeft and node isLeft 
    //        or parent isRight and node isRight
    if ((isLeft && parentIsLeft) || (isRight && parentIsRight)) {
      // Analysis for when the parent is on the left:
      // (right is symmetric).
      // The subtree must have been balanced before the insertion, so the subtrees
      // ? must have an identical number of black nodes, and the uncle must be the
      // head of one of those subtrees.
      // The subtree ?(B) must have a black as it's root, since the parent was red.
      //
      //            G(B) 
      //           /    \
      //        P(R)     U(B) ~ ?
      //       /   \     
      //    N(R)    ?(B)  
      //    /  \
      //   ?    ?
      //
      // If we paint the parent black, the grandparent red and the uncle red 
      // and rotate left (on the grandparent), we obtain
      //
      //            P(B) 
      //           /    \
      //        N(R)     G(R)
      //       /   \     /  \
      //      ?     ?  ?(B)  U(B) ~ ?
      //
      // Since the subtrees must contain at most one black node each, and the new left subtree
      grandParent.colour = RED;
      parent.colour = BLACK;
      if (parentIsLeft) {
        grandParent.rotateLeft();
      } else {
        grandParent.rotateRight();
      }
      return;
    }
    //We should match one of the above cases.
    assert(false);
  }
  
  RedBlackTree<T> _remove(T data) {
    if (isInit) {
      // There has been no data inserted into the tree yet.
      return this;
    }
    var removeAt = _find(data);
    if (removeAt is TreeLeaf) {
      //The data wasn't found in the tree
      return;
    }
    var replaceWith = removeNode;
    while (removeAt is! TreeLeaf) {
      final removeNode = removeAt as TreeNode;
      removeNode.colour = RED;
      if (replaceWith == null) {
        removeNode.childLeft.parent = removeNode.parent;
        removeNode.childLeft.colour = RED;
        removeAt = removeNode.childLeft;
        replaceWith = removeNode.childRight;
      }
      final cmp = comparator(removeNode.data, replaceWith.data);
      if (cmp < 0) {
        final savRight = removeNode.childRight;
        removeNode.childRight = replaceWith;
        replaceWith = savRight;
        removeAt = replaceWith.childLeft;
      }
      if (cmp > 0) {
        final savLeft = removeNode.childLeft;
        removeNode.childLeft = replaceWith;
        replaceWith = savRight;
        removeAt = replaceWith.childRight;
      }
    }
    final p = removeAt.parent;
    final cmp = comparator(replaceWith.data, parent.data);
    if (cmp < 0) {
      removeAt.childLeft = replaceWith;
    }
    _repaint_remove();
  }
  
  void _repaint_remove() {
    assert(colour == RED);
    
    //CASE 1: We are the root node
    if (parent == null) {
      colour = BLACK;
      return;
    }
    
    //CASE 2: Our parent is coloured black
    //Since we coloured every node between the node removed and the leaf RED, we must be done
    if (parent.colour == BLACK) return;
    // CASE 3: Both of our children are black
    if (childLeft.colour == BLACK && childRight.colour == BLACK) {
      //If both children are black, then either they are both leaves,
      //or we have already repainted the tree below them, so both sides
      //must be balanced.
      //Continue repainting our parent.
      parent._repaint_remove();
    }
    //One of our children must be red, so colour the current node black
    colour = BLACK;
    //       P(R)
    //      /    \
    //   S(?)     N(B)     
    //           /    \
    //        1(R)     2(?)
    //       /    \
    //    3(B)     4(B)
    //Since we are repainting the tree N, we must have rebalanced the tree
    //below N, thus subtrees 1 and 2 contain the same number of 
    if (sibling.colour == RED) {
      
    }
  }
  
  RedBlackTree<T> _find(T data) {
    if (isInit) return this;
    var n = this;
    while(n is! TreeLeaf) {
      var cmp = comparator((n as TreeNode).data, data);
      if (cmp == 0) return n;
      if (cmp > 0) { n = n.childRight; continue; }
      if (cmp < 0) { n = n.childLeft; continue; }
    }
    // The data was not found in the tree.
    return n;
  }
  
  
  
  /**
   * Replace the node in the tree by it's left child, while
   * preserving the order of the tree.
   * Throws a [StateError] if the left child is a leaf of the tree.
   */
  void rotateLeft() {
    if (childLeft is TreeLeaf) {
      throw new StateError("Cannot rotate leaf into current node's position");
    }
    final newRoot = childLeft as TreeNode;
    final saveRight = newRoot.childRight;
    if (parent != null) {
      if (_isLeft) { 
        parent.childLeft = newRoot;
      } else {
        parent.childRight = newRoot;
      }
    } else {
      newRoot._parent = null;
    }
    childLeft = saveRight;
    newRoot.childRight = this;
  }
  
  /**
   * Replace the node in the tree by it's right child, while
   * preserving the order of the tree.
   * Throws a [StateError] if the right child is a leaf of the tree
   */
  void rotateRight() {
    if (childRight is TreeLeaf) {
      throw new StateError("Cannot rotate leaf into current node's position");
    }
    final newRoot = childRight as TreeNode;
    final saveLeft = newRoot.childLeft;
    if (parent != null) {
      if (_isLeft) {
        parent.childLeft = newRoot;
      } else {
        parent.childRight = newRoot;
      }
    } else {
      newRoot._parent = null;
    }
    childRight = saveLeft;
    newRoot.childLeft = this;
  }
  
  bool operator ==(Object o) {
    if (o is TreeNode) {
      var n = (o as TreeNode);
      return comparator(data, n.data)== 0 
          && n._childLeft == _childLeft
          && n._childRight == _childRight;
    }
    return false;
  }
  
  String __str({indent: 0}) {
    var i = new List.filled(indent, "\t").join();
    return "Node(\n"
           "$i\t${colour ? "RED" : "BLACK"}\n"
           "$i\t$data\n"
           "$i\t${childLeft.__str(indent: indent + 1)}\n"
           "$i\t${childRight.__str(indent: indent + 1)}\n"
           "$i)";
  }
  
  String toString() => __str();
}

class TreeLeaf<T> extends RedBlackTree<T> {
  //All leaves are black
  bool get colour => BLACK;
  
  TreeLeaf._() : super._();
  
  bool operator ==(Object o) {
    return (o is TreeLeaf);
  }
  
  String __str({indent: 0}) {
    return "Leaf(BLACK)";
  }
  
  String toString() => __str();
}