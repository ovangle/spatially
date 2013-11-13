part of base;

/**
 * Abstract implementation of an [Array].
 * 
 * All operations are defined in terms of `length`,
 * `operator[]` and `operator[]=`, which need to be implemented
 */
abstract class ArrayMixin<T> implements Array<T> {
  _ListMixinDelegate __delegate;
  _ListMixinDelegate get _delegate {
    if (__delegate == null) {
      __delegate = new _ListMixinDelegate<T>(this);
    }
    return __delegate;
  }
  
  void swap(int i, int j) {
    if (i < 0 || i >= length) throw new RangeError.range(i, 0, length - 1);
    if (j < 0 || j >= length) throw new RangeError.range(i, 0, length - 1);
    if (i == j) return;
    final tmp = this[i];
    this[i] = this[j];
    this[j] = tmp;
  }
  
  Array<T> get reversed {
    Array<T> arr = new Array<T>.from(this);
    arr.reverse();
    return arr;
  }
  void reverse() {
    for (int i=0;i<length/2; i++) {
      swap(i, length - 1 - i);
    }
  }
  
  bool get isEmpty => length == 0;
  bool get isNotEmpty => !isEmpty;
  
  Array<T> subarray(int start, [int end]) {
    if (end == null) end = this.length;
    if (start < 0 || start > length) {
      throw new RangeError.range(start, 0, this.length);
    }
    if (end < start || end > this.length) {
      throw new RangeError.range(end, start, this.length);
    }
    return new Array<T>.from(getRange(start, end));
  }
  Iterator<T> get iterator => _delegate.iterator;
  T get single => _delegate.single;
  
  Iterable<T> getRange(int start, int end) =>
      _delegate.getRange(start, end);
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount=0]) {
    _delegate.setRange(start, end, iterable, skipCount);
  }
  void fillRange(int start, int end, [T fill]) =>
      _delegate.fillRange(start, end, fill);
  void setAll(int start, Iterable<T> iterable) =>
      _delegate.setAll(start, iterable);
  Iterable<T> take(int count) => _delegate.take(count);
  Iterable<T> skip(int count) => _delegate.skip(count);
  
  Iterable<T> takeWhile(bool test(T element)) =>
      _delegate.takeWhile(test);
  Iterable<T> skipWhile(bool test(T element)) =>
      _delegate.skipWhile(test);
  
  bool any(bool test(T element)) => 
      _delegate.any(test);
  bool every(bool test(T element)) =>
      _delegate.every(test);
  
  Iterable<dynamic> map(dynamic f(T elem)) =>
      _delegate.map(f);
  
  Iterable<T> where(bool test(T element)) =>
      _delegate.where(test);
  T firstWhere(bool test(T element), {Object orElse(): null}) =>
      _delegate.firstWhere(test, orElse: orElse);
  T lastWhere(bool test(T element), {Object orElse(): null}) =>
      _delegate.lastWhere(test, orElse: orElse);
  T singleWhere(bool test(T element)) =>
      _delegate.singleWhere(test);
  
  Iterable<T> expand(Iterable<T> f(T elem)) =>
    _delegate.expand(f);
  
  T get first => _delegate.first;
  T get last => _delegate.last;
  
  List<T> toList({bool growable: true}) => 
      _delegate.toList(growable: growable);
  Set<T> toSet() => _delegate.toSet();
  Map<int, T> asMap() => _delegate.asMap();
  
  int indexOf(T value, [int start]) => 
      _delegate.indexOf(value, start);
  int lastIndexOf(T value, [int start]) =>
      _delegate.lastIndexOf(value, start);
  T elementAt(int i) => 
      _delegate.elementAt(i);
  bool contains(T value) =>
      _delegate.contains(value);
  
  void forEach(void action(T element)) =>
      _delegate.forEach(action);
  
  String join([String seperator = '']) =>
      _delegate.join(seperator);
  
  dynamic fold(dynamic initialValue, 
               dynamic combine(dynamic result, T element)) =>
      _delegate.fold(initialValue, combine);
  T reduce(T combine(T element1, T element2)) =>
      _delegate.reduce(combine);
  
  void sort([Comparator<T> compare]) {
    _delegate.sort(compare);
  }
  void shuffle([math.Random random]) {
    _delegate.shuffle(random);
  }
  
  
  int get length;
  T operator [](int i);
  void operator []=(int i, T value);
}

class _ListMixinDelegate<T> extends ListMixin<T> {
  ArrayMixin<T> _arrayMixin;
  _ListMixinDelegate(ArrayMixin<T> this._arrayMixin);
  
  int get length => _arrayMixin.length;
      set length(T value) {
        assert(false);
      }
  
  T operator [](int i) => _arrayMixin[i];
  void operator []=(int i, T value) {
    _arrayMixin[i] = value;
  }
}