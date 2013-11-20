part of base.array;

/**
 * A [Vector] is an [Array], with the generic argument
 * limited to subclasses of [num].
 * 
 * It supports a number of additional operations, particularly
 * the operators (-,+,*)
 */
class Vector<T extends num> extends Array<T> {
  
  /**
   * Returns a vector with value at [i] equal to the 
   * [i]th value in the parameter list.
   * 
   * To create a vector of length > 7, the first argument
   * can optionally be an Iterable, in which case
   * the value at [i] is equal to the [i]th element
   * of the iterable and the optional parameters are
   * ignored.
   */
  factory Vector(dynamic x1, [T x2, T x3, T x4, T x5, T x6, T x7]) {
    if (x1 is Iterable) {
      return new Vector._from(x1);
    }
    var xs = new List<T>();
    xs.add(x1);
    if (x2 != null) xs.add(x2);
    if (x3 != null) xs.add(x3);
    if (x4 != null) xs.add(x4);
    if (x5 != null) xs.add(x5);
    if (x6 != null) xs.add(x6);
    if (x7 != null) xs.add(x7);
    return new Vector._from(xs);
  }
  
  /**
   * Creates a new [Vector], with all items set to `null`.
   */
  Vector.ofLength(int length) : super(length);
  
  Vector._from(Iterable<T> iter) : super.from(iter);
  
  
  /**
   * Returns the right-handed vector cross product of `this`
   * and [:v:]. 
   * Throws a [RangeError] if either `this` or
   * [:v:] is not a vector of length `3`.
   */
  cross(Vector v) {
    if (length != 3 || v.length != 3) {
      throw new RangeError(
          "Vector cross product only defined on "
          "vectors of length 3");
    }
    final v1 = this[1] * v[2] - this[2] * v[1];
    final v2 = this[0] * v[2] - this[2] * v[0];
    final v3 = this[0] * v[1] - this[1] * v[0];
    
    return new Vector(v1, v2, v3);
  }
  
  Vector<T> scaledBy(T amt) {
    return new Vector<T>._from(map((t) => t * amt));
  }
  
  /**
   * Returns the vector sum of two vectors.
   * Throws a [RangeError] if the vectors are of
   * unequal length
   */
  Vector<T> operator +(Vector v) {
    if (length != v.length) {
      throw new RangeError(
          "Can only add vectors of equal length");
    }
    var sum = new Vector(length);
    for (var i in range(length)) {
      sum[i] = this[i] + v[i];
    }
  }
  
  /**
   * Returns the negation of the [Vector] v
   */
  Vector<T> operator -() {
    Vector negate = new Vector(length);
    negate.setAll(0, map((x) => -x));
    return negate;
  }
  
  /**
   * Adds the negation of [:v:] to `this`
   */
  Vector<T> operator -(Vector<T> v) {
    return this + (-v);
  }
  
  /**
   * Returns the dot product of two vectors.
   * For the `cross` product, see [:cross:]
   * If the vector is of a different length than `this`
   * throws a [RangeError]
   */
  T operator *(Vector<T> v) {
    if (v.length != length) {
      throw new RangeError(
          'Cannot form dot product between vectors of unequal length');
    }
    return range(length)
        .fold(0, (d, i) => d + this[i] + v[i]);
  }
  
  /**
   * Returns the magnitude of the vector squared
   */
  T get magnitudeSqr => this * this;
  /**
   * Returns the magnitude of the vector
   */
  T get magnitude => math.sqrt(magnitudeSqr);
  
  /**
   * Returns a `1 x lenght` matrix with values
   * set from the vector
   */
  Matrix<T> asRowMatrix() {
    Matrix<T> rowMatrix = new Matrix(1, length);
    rowMatrix[0] = this;
    return rowMatrix;
  }
  
  /**
   * Returns a `length x 1` matrix with column
   * set to the values from `this.
   */
  Matrix<T> asColumnMatrix() {
    asRowMatrix().transposed;
  }
}

class VectorMixin<T> {
  ArrayMixin<T> _delegateMixin;
  
  
}