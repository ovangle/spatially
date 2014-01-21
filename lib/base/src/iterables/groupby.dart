part of spatially.base.iterables;

/**
 * Returns an [Iterable] of [Group]s, where each element
 * contains all elements of the [Iterable] which agree on the
 * values returned by the provided key function.
 */
Iterable<Group> groupBy(Iterable iterable, { key(var k) }) {
  if (key == null) {
    key = (x) => x;
  }
  return new _GroupByIterable(iterable, key);
}

class _GroupByIterable<K,E>
extends Object with IterableMixin<Group<K,E>> {
  final List<Tuple<K,E>> _keyedIterable;

  _GroupByIterable(Iterable<E> iterable, K key(E value)) :
    _keyedIterable = new List.from(zip(iterable.map(key), iterable), growable: false);

  Iterator<Group<K,E>> get iterator =>
      new _GroupByIterator(_keyedIterable);
}

class _GroupByIterator<K,E> implements Iterator<Group<K,E>> {
  final List<Tuple<K,E>> _keyedIterable;

  int _keyIdx = -1;
  Set<K> _seenKeys;
  Group<K,E> _current;

  _GroupByIterator(List<Tuple<K,E>> this._keyedIterable) :
    _seenKeys = new Set<K>();

  Group<K,E> get current => _current;

  bool moveNext() {
    var key;
    while (++_keyIdx < _keyedIterable.length) {
      var pair = _keyedIterable[_keyIdx];
      if (!_seenKeys.contains(pair.$1)) {
        key = pair.$1;
        break;
      }
    }
    if (key == null) {
      _current = null;
      return false;
    }
    _seenKeys.add(key);
    //If doing this without tuples, would need to index
    //both the keys and the elements.
    var values = _keyedIterable
        .where((p) => p.$1 == key)
        .map((p) => p.$2);

    _current = new Group(key, values);
    return true;
  }
}