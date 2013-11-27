part of base.array;

/**
 * An [Array] is a non-extendable [List]
 */
class Array<T> extends Object with IterableMixin<T> {
  final List<T> _delegate;
  
  Array(int length) : 
    _delegate = new List(length);
  
  Array.filled(int length, T fill) :
    _delegate = new List.filled(length, fill);
  
  Array.from(Iterable<T> iter) :
    _delegate = new List<T>.from(iter, growable: false);

  /**
   * Creates an [Array] from the given [List].
   * The [List] should be non-extendable to yield the 
   * performance benefits of using arrays, but this is not
   * checked by the constructor.
   */
  const Array.fromList(List<T> this._delegate);
  
  T operator [](int i) => _delegate[i];
  void operator []=(int i, T value) {
    _delegate[i] = value;
  }
  Iterator<T> get iterator => _delegate.iterator;
  int get length => _delegate.length;
  
  /**
   * Returns an [Array] of the elements in the current
   * array, in the reverse order.
   */
  Array<T> get reversed => new Array<T>.from(_delegate.reversed);
  
  /**
   * Reverses the elements of this [Array] in place.
   */
  void reverse() {
    for (int i=0;i<length / 2; i++)
      swap(i, length - 1 - i);
  }
  
  /**
   * Swap the [i]th and [j]th elements of `this`.
   */
  void swap(int i, int j) {
    if (i < 0 || i >= length) throw new RangeError.range(i, 0, length - 1);
    if (j < 0 || j >= length) throw new RangeError.range(i, 0, length - 1);
    if (i == j) return;
    var tmp = this[i];
    this[i] = this[j];
    this[j] = tmp;
  }
  
  int indexOf(T e, [int start = 0]) => _delegate.indexOf(e, start);
  int lastIndexOf(T e, [int start=0]) => _delegate.indexOf(e, start);
  
  void sort([Comparator<T> comparator]) => _delegate.sort(comparator);
  void shuffle(math.Random random) => _delegate.shuffle(random);
   
  Iterable<T> getRange(int start, int end) => _delegate.getRange(start, end);
  
  void setRange(int start, int end, Iterable<T> iterable, [int skipCount]) =>
      _delegate.setRange(start, end, iterable, skipCount);
  void fillRange(int start, int end, [T fillValue]) =>
      _delegate.fillRange(start, end, fillValue);
  void setAll(int index, Iterable<T> iterable) =>
      _delegate.setAll(index, iterable);
  
  Array<T> subarray(int start, [int end]) =>
      new Array.from(_delegate.sublist(start, end));
  
  List<T> toList({growable: true}) => _delegate.toList(growable: growable);
  Map<int, T> asMap() => _delegate.asMap();
}
   