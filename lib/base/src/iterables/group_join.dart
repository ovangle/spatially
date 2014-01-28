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


part of spatially.base.iterables;

Iterable<Group> groupJoin(Iterable innerIterable,
                          Iterable outerIterable,
                          { bool on(innerElement, outerElement) }) {
  if (on == null)
    on = (x,y) => x == y;
  return new _GroupJoin(innerIterable, outerIterable, on);
}

/**
 * An [:innerJoin:] performs an *SQL* style `INNER JOIN` operation on
 * two iterables, returning an [Iterable] of [InnerJoinReult]s which
 * contains all pairs of values in both iterables which agree on the
 * given key functions.
 */
Iterable<InnerJoinResult> innerJoin(Iterable innerIterable,
                                    Iterable outerIterable,
                                    { bool on(innerElement, outerElement) }) {
  var grpJoin = groupJoin(innerIterable, outerIterable, on: on);
  return grpJoin
      .where((grp) => grp.values.isNotEmpty)
      .expand((grp) => grp.values.map((v) => new InnerJoinResult(grp.key, v)));
}

class InnerJoinResult<E1,E2> {
  final E1 left;
  final E2 right;

  InnerJoinResult(this.left, this.right);

  bool operator ==(Object other) =>
      other is InnerJoinResult && left == other.left && right == other.right;

  int get hashCode =>
      ((left.hashCode * 37) + right.hashCode) * 37;

  String toString() => "InnerJoinResult($left, $right)";
}

/**
 * [:leftOuterJoin:] performs an *SQL* style `LEFT OUTER JOIN` operation on
 * the elements of the two iterables, returning an [Iterable] of [OuterJoinResult]
 * instances.
 *
 * If a given element of the inner iterable has no corresponding elements in the
 * outer iterable or if the matched outerIterable element is `null`, the resulting
 * [OuterJoinResult] will have be absent.
 */
Iterable<OuterJoinResult> leftOuterJoin(Iterable innerIterable,
                                        Iterable outerIterable,
                                        { bool on(innerElement, outerElement)}) {
  var grpJoin = groupJoin(innerIterable, outerIterable, on: on);
  return grpJoin
      .expand((grp) {
        if (grp.values.isEmpty) {
          return [ new OuterJoinResult(grp.key, new Optional.absent()) ];
        } else {
          return grp.values.map((v) => new OuterJoinResult(grp.key, new Optional.fromNullable(v)));
        }
      });
}

class OuterJoinResult<E1,E2> {
  final E1 left;
  final Optional<E2> right;
  OuterJoinResult(this.left, this.right);

  bool operator ==(Object other) =>
      other is OuterJoinResult && other.left == left && other.right == right;

  int get hashCode =>
      ((left.hashCode * 31) + right.hashCode) * 31;

  String toString() => "OuterJoinResult($left, $right)";
}

typedef bool Predicate<E1,E2>(E1 innervalue, E2 outerValue);

class _GroupJoin<E1,E2>
extends Object with IterableMixin<Group<E1,E2>> {
  final Iterable<E1> _innerIterable;
  final Iterable<E2> _outerIterable;
  final Predicate<E1,E2> _on;

  _GroupJoin(Iterable<E1> this._innerIterable,
             Iterable<E2> this._outerIterable,
             bool this._on(E1 innerElement, E2 outerElement));

  Iterator<Group<E1,E2>> get iterator =>
     new _GroupJoinIterator(_innerIterable, _outerIterable, _on);
}

class _GroupJoinIterator<E1,E2> implements Iterator<Group<E1,E2>> {
  final Iterator<E1> _innerIterator;
  final Iterable<E2> _outerIterable;

  final Predicate<E1,E2> _on;
  Group<E1,E2> _current;

  _GroupJoinIterator(innerIterable, this._outerIterable, this._on) :
    _innerIterator = innerIterable.iterator,
    _current = null;

  Group<E1,E2> get current => _current;

  bool moveNext() {
    bool hasNext = _innerIterator.moveNext();
    if (hasNext) {
      var key = _innerIterator.current;
      _current =
          new Group(key, _outerIterable.where((v) => _on(key, v)));
    } else {
      _current = null;
    }
    return hasNext;
  }
}