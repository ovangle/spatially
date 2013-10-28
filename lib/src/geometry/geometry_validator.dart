part of geometry;

abstract class _GeometryValidator<T> {
  List<T> validated;
  
  _GeometryValidator(GeometryList<T> this.validated);
  
  onAdd(T geometry);
  onAddAll(Iterable<T> geometries);
  
  onInsert(int index, T geometry);
  onInsertAll(int index, Iterable<T> geometries);

  onRemove(T geometry);
  onRemoveAt(int index);
  onRemoveWhere(bool test(T geom));
  onRetainWhere(bool test(T geom));
  
  onSetAll(int index, Iterable<T> iterable);
  onClear();
  
  onFillRange(int start, int end, T fillValue);
  onReplaceRange(int start, int end, Iterable<T> geometries);
  onSetRange(int start, int end, Iterable<T> geometries);
  
  dynamic get immutableCopy;
}