library spatially.base.tuple;

import 'dart:collection';

import 'package:quiver/core.dart' show hash2;


class Tuple<T1,T2> {
  final T1 $1;
  final T2 $2;

  Tuple(T1 this.$1, T2 this.$2);

  Tuple transform(dynamic f1(T1 item), dynamic f2(T2 item)) =>
      new Tuple(f1($1), f2($2));

  dynamic project(int i) {
    switch(i) {
      case 1:
        return $1;
      case 2:
        return $2;
      default:
        throw new RangeError.range(i, 1, 2);
    }
  }

  dynamic projectOther(int i) {
    return project(3 - i);
  }

  bool operator ==(Object other) =>
      other is Tuple<T1,T2> && $1 == other.$1 && $2 == other.$2;

  int get hashCode => hash2($1, $2);

  String toString() => "<${this.$1}, ${this.$2}>";
}

Iterable<Tuple> zip(Iterable iter1, Iterable iter2) {
  return new _Zip(iter1, iter2);
}

Iterable zipWith(Iterable iter1, Iterable iter2, dynamic f(var elem1, var elem2)) =>
    new _ZipWith(iter1, iter2, f);

class _Zip<T1,T2>
extends Object with IterableMixin<Tuple<T1,T2>>
implements Iterable<Tuple<T1,T2>>
{
  Iterable<T1> _iterable1;
  Iterable<T2> _iterable2;

  _Zip(Iterable<T1> this._iterable1, Iterable<T2> this._iterable2);

  Iterator<Tuple<T1,T2>> get iterator => new _TupleIterator(_iterable1, _iterable2);

}

class _TupleIterator<T1,T2> implements Iterator<Tuple<T1,T2>> {
  Iterator<T1> iterator1;
  Iterator<T2> iterator2;
  Tuple<T1,T2> _current = null;

  _TupleIterator(Iterable<T1> iterable1, Iterable<T2> iterable2) :
    iterator1 = iterable1.iterator,
    iterator2 = iterable2.iterator;

  Tuple<T1,T2> get current => _current;

  bool moveNext() {
    if (!(iterator1.moveNext() && iterator2.moveNext())) {
      _current = null;
      return false;
    }
    _current = new Tuple(iterator1.current, iterator2.current);
    return true;
  }
}

class _ZipWith<T1,T2,R>
extends Object with IterableMixin<R>
implements Iterable<R> {
  Iterable<T1> _iterable1;
  Iterable<T2> _iterable2;
  var _with;
  Tuple<T1,T2> _current = null;

  _ZipWith(Iterable<T1> this._iterable1, Iterable<T2> this._iterable2, R this._with(T1 elem1, T2 elem2));

  Iterator<R> get iterator => new _ZipWithIterator(_iterable1, _iterable2, _with);
}

class _ZipWithIterator<T1,T2,R> implements Iterator<R> {
  Iterator<T1> _iterator1;
  Iterator<T2> _iterator2;
  R _current;
  var _with;

  _ZipWithIterator(Iterable<T1> iterable1, Iterable<T2> iterable2, R this._with(T1 elem1, T2 elem2)):
    _iterator1 = iterable1.iterator,
    _iterator2 = iterable2.iterator;

  R get current => _current;

  bool moveNext() {
    if (!(_iterator1.moveNext() && _iterator2.moveNext())) {
      _current = null;
      return false;
    }
    _current = _with(_iterator1.current, _iterator2.current);
    return true;
  }
}