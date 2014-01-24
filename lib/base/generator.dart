library spatially.base.generator;

import 'dart:collection';

class _BreakSentinel {
  const _BreakSentinel();
}

const _BreakSentinel yieldBreak = const _BreakSentinel();

/**
 * Create a lazy iterable from the results of the function `f`.
 *
 * Each time the generator is iterated, the function will be called
 * a single time with a `true` value, which begins the iteration.
 *
 * Any time the function is called with a `true` value, it should reset
 * any state, so the iterator can be resumed.
 *
 * The iteration continues until `f` returns `null`.
 *
 * If `breakOnNull` is `false`, iteration continues until `f` returns
 * the value [yieldBreak]. This makes it possible to return iterables
 * which contain `null` values.
 *
 * The values returned after receiving the first `null` or [yieldBreak]
 * value are ignored unless `f` is called again with the value.
 *
 * Attempting to iterate over a generator while another iterator.
 * is still running will raise a [ConcurrentIterationError]. Thus
 * functions which return generators should always maintain local state
 * so that they can be called to get a new generator.
 *
 * eg.
 *
        range(int start, int stop, int step) {
          int i;
          generator(bool isInit) {
            if (isInit) {
              i = start;
              return i;
            }
            i+= step;
            if (i >= stop)
              return null;
            return i;
          }
          return generate(generator);
        }

        var r = range(0, 10, 2);
        for (var i1 in r) {
          for (var i2 in r) {
            //throws ConcurrentIterationError
          }
        }

        for (var i1 in range(0, 10, 2) {
          for (var i2 in range(0, 10, 2) {
            //No error raised
          }
        }
 *
 */
Iterable generate(dynamic f(bool isInit), {bool breakOnNull: true}) =>
  new _GenerateIterable(f, breakOnNull);



/**
 * yields a finite set of values without allocating a list.
 *
     var values = yield (4, () =>
                  yield (5, () =>
                  yield (6)));
     //prints (4,5,6)
     print(values.toList());

 * To create an empty iterable, you can use `yield(yieldBreak)`.
 */
Iterable yield(dynamic value, [Iterable yieldContinue()]) {
  Iterator iterator;
  yieldGenerate(bool isInit) {
    if (isInit) {
      return value;
    }
    if (yieldContinue == null)
      return yieldBreak;
    if (iterator == null)
      iterator = yieldContinue().iterator;
    if (!iterator.moveNext()) {
      return yieldBreak;
    }
    return iterator.current;
  }
  return generate(yieldGenerate, breakOnNull: false);
}

typedef T _Generator<T>(bool isInit);

class _GenerateIterable<T> extends IterableBase<T> {
  bool _isIterating = false;
  final _Generator<T> _generator;
  final bool _breakOnNull;

  _GenerateIterable(this._generator, this._breakOnNull);

  Iterator<T> get iterator {
    //TODO (ovangle): When debugger bugs are fixed
    // if (_isIterating) {
    //   throw new ConcurrentModificationError();
    // }
    return new _GenerateIterator(this);
  }
}


class ConcurrentIterationError extends Error {
  ConcurrentIterationError();

  String toString() => "Concurrent iteration of generator";
}

class _GenerateIterator<T> implements Iterator<T> {
  final _GenerateIterable<T> _iterable;
  final _Generator<T> _generator;
  final bool _breakOnNull;

  T _current;
  bool _isInit = true;
  bool _isBreak = false;

  _GenerateIterator(_GenerateIterable<T> iterable) :
    _generator = iterable._generator,
    _breakOnNull = iterable._breakOnNull,
    _iterable = iterable;

  T get current => _current;

  bool moveNext() {
    if (_isBreak) {
      return false;
    }
    _current = _generator(_isInit);
    _isInit = false;
    if (_breakOnNull) {
      _isBreak = _current == null;
    } else {
      _isBreak = _current == yieldBreak;
    }
    _iterable._isIterating = !_isBreak;
    return !_isBreak;
  }
}