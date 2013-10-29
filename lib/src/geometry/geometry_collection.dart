part of geometry;

abstract class GeometryCollection<T> extends Geometry with IterableMixin<T> {
  final List<T> _geometries;
  
  Iterator<T> get iterator => _geometries.iterator;
  
  GeometryCollection(Iterable<T> geometries, bool growable)
      : _geometries = new List<T>.from(geometries, growable: growable);
  
  /**
   * Returns the minimum [Bounds] object which contains every [Geometry] in the collection.
   * Throws a [StateError] if the collection is empty.
   */
  Bounds get bounds {
    if (isEmpty) throw new StateError("Empty ${this.runtimeType} has no bounds");
    return fold((first as Geometry).bounds, (bounds, geom) => bounds.extend(geom));
  }
  
  /**
   * The distance from a [GeometryCollection] to [:geom:]
   * is the minimum distance from any of it's component geometries
   */
  double distanceTo(Point geom) {
    return map((g) => (g as Geometry).distanceTo(geom))
          .fold(double.INFINITY, math.min);
  }
  /*
  double geodesicDistanceTo(Geometry geom) {
    return map((g) => g.geodesicDistanceTo(geom))
          .fold(double.INFINITY, math.min);
  }
  */
  
  //Relations
  
  bool equalTo(Geometry other, {double tolerance: 1e-15}) {
    if (other is! GeometryCollection) return false;
    GeometryCollection oList = other as GeometryCollection;
    if (length != oList.length) return false;
    for (var i in range(length)) {
      if (!(this[i] as Geometry).equalTo(oList[i], tolerance: tolerance)) return false;
    }
    return true;
  }
  
  bool intersects(Geometry geom, {double tolerance: 1e-15}) {
    return any((g) => (g as Geometry).intersects(geom, tolerance: tolerance));
  }
  
  /**
   * Returns the [:i:]th geometry in the iterable.
   */
  T operator[](int i) => _geometries[i];
}