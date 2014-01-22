library spatially.base.linkedlist;

import 'dart:collection';

class _ListNode<T> {
  LinkedList<T> _list;
  T value;
  _ListNode<T> _next;
  _ListNode<T> _prev;

  _ListNode(LinkedList<T> this._list, T this.value);

  bool get isLast => _next is _LastSentinel;
  bool get isFirst => _prev is _HeadSentinel;

  void unlink() {
    _next = null;
    _prev = null;
    _list = null;
  }

  void link(_ListNode<T> prev, _ListNode<T> next) {
    this.prev = prev;
    this.next = next;
  }

  LinkedList<T> get list => _list;

  _ListNode<T> get next => _next;
  void set next(_ListNode<T> node) {
    assert(node != null);
    this._next = node;
    node._prev = this;
  }

  _ListNode<T> get prev => _prev;
  void set prev(_ListNode<T> node) {
    assert(node != null);
    this._prev = node;
    if (node != null) {
      node._next = this;
    }
  }

  String toString() => "ListNode($value)";
}

class _HeadSentinel extends _ListNode {
  _HeadSentinel(LinkedList list) : super(list, null);

  _ListNode _next;
  get next => _next;
  set next(_ListNode node) {
    assert(node != null);
    _next = node;
    node._prev = this;
  }

  get prev => null;
  set prev(_ListNode value) {
    assert(false);
  }

  String toString() => "__HEAD__";

}

class _LastSentinel extends _ListNode {
  _LastSentinel(LinkedList list) : super(list, null);

  get prev => _prev;
  set prev(_ListNode node) {
    assert(node != null);
    _prev = node;
    node._next = this;
  }

  get next => null;
  set next(_ListNode value) {
    assert(false);
  }

  String toString() => "__LAST__";
}

class ListNodeView<T> {
  _ListNode<T> _node;
  ListNodeView<T> get next {
    if (_node.isLast)
      return null;
    return new ListNodeView._(_node.next);
  }

  ListNodeView<T> get prev {
    if (_node.isFirst)
      return null;
    return new ListNodeView._(_node.prev);
  }

  T get value => _node.value;

  void insertAfter(T value) {
    _node.list.insertAfter(this, value);
  }

  void insertBefore(T value) {
    _node.list.insertBefore(this, value);
  }

  ListNodeView._(_ListNode<T> this._node);
}

class LinkedList<T>
extends Object with IterableMixin<T> {
  _ListNode<T> _lastsentinel;
  _ListNode<T> _headsentinel;
  int _length;
  int _modificationCount;

  LinkedList() {
    _headsentinel = new _HeadSentinel(this);
    _lastsentinel = new _LastSentinel(this);
    _headsentinel.next = _lastsentinel;
    _length = 0;
    _modificationCount = 0;
  }

  factory LinkedList.from(Iterable<T> iterable) {
    LinkedList li = new LinkedList();
    li.addAll(iterable);
    return li;
  }

  Iterator<T> get iterator => new _LinkedListIterator(this);

  void add(T value) {
    _insertAfter(_lastsentinel.prev, value);
  }

  void addAll(Iterable<T> values) {
    values.forEach(add);
  }

  void addFirst(T value) {
    _insertAfter(_headsentinel, value);
  }

  T removeFirst() {
    if (_lastsentinel.isFirst)
      throw new StateError("No elements");
    return _unlink(_headsentinel.next);
  }

  T removeLast() {
    if (_headsentinel.isLast)
      return throw new StateError("No elements");
    return _unlink(_lastsentinel.prev);
  }

  _nodeAt(int i) {
    if (i < 0 || i >= _length) {
      throw new RangeError.range(i, 0, _length - 1);
    }
    var _curr = _headsentinel;
    while (i-- >= 0 && _curr is! _LastSentinel)
      _curr = _curr.next;
    return _curr;
  }

  ListNodeView<T> nodeAt(int i) {
    return new ListNodeView._(_nodeAt(i));
  }

  void remove(ListNodeView<T> node) {
    _unlink(node._node);
  }

  void insert(int i, T value) {
    _insertAfter(_nodeAt(i), value);
  }

  T insertAfter(ListNodeView<T> node, T value) {
    return _insertAfter(node._node, value);
  }

  T insertBefore(ListNodeView<T> node, T value) {
    return _insertAfter(node._node._prev, value);
  }

  _insertAfter(_ListNode<T> node, T value) {
    _modificationCount++;
    var insertNode = new _ListNode<T>(this, value);
    insertNode.link(node, node.next);
    _length++;
  }

  T _unlink(_ListNode<T> node) {
    _modificationCount++;
    node._prev.next = node.next;
    node.unlink();
    _length--;
    return node.value;
  }

  void clear() {
    _modificationCount++;
    var curr = _headsentinel.next;
    assert(curr.isFirst);
    while (curr.next.isLast) {
      //unlink so GC can collect.
      var next = curr.next;
      curr.unlink();
      curr = next;
    }
    _headsentinel.next = _lastsentinel;
    _length = 0;
  }

  bool get isEmpty => _headsentinel.isLast;

  T get first {
    if (_lastsentinel.isFirst) {
      throw new StateError("No elements");
    }
    return _headsentinel.next.value;
  }

  T get last {
    if (_headsentinel.isLast) {
      throw new StateError("No elements");
    }
    return _lastsentinel.prev.value;
  }

  T get single {
    if (_headsentinel.isLast) {
      throw new StateError("No elements");
    }
    if (_length > 1) {
      throw new StateError("Too many elements");
    }
    return _headsentinel.next.value;
  }
}

class _LinkedListIterator<T> implements Iterator<T> {
  LinkedList<T> _list;
  int _modificationCount;
  _ListNode<T> _currNode;

  _LinkedListIterator(LinkedList<T> list) :
    _list = list,
    _currNode = list._headsentinel,
    _modificationCount = list._modificationCount;

  T get current => _currNode.value;

  bool moveNext() {
    if (_currNode is _LastSentinel)
      return false;
    if (_currNode.isLast) {
      _currNode = _currNode.next;
      return false;
    }
    if (_modificationCount != _list._modificationCount) {
      throw new ConcurrentModificationError("List changed while iterating");
    }
    _currNode = _currNode.next;
    return true;

  }
}


