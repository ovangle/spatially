part of base.array;

/**
 * Solves a n x n system of linear equations
 *    | ax1 + ax2 + . . . + axn | | p1 |     | v1 |
 *    | bx1 + bx2 + . . . + bxn | | p2 |     | v2 |
 *    |  .          .        .  | | .  |. =  | .  |
 *    |  .            .      .  | | .  |     | .  |
 *    |  .              .    .  | | .  |     | .  |
 *    | zx1 + zx2 + . . . + zxn | | pn |     | vn |
 *    
 * Using the gaussian matrix elimination algorithm.
 * 
 * Returns the vector (p1, ..., pn) if the system
 * of equations has a solution otherwise returns `null`
 */
Vector solveMatrix(Matrix system, Vector equalTo) {
  if (!system.isSquare) {
    throw new ArgumentError("system must be a square matrix");
  }
  final int n = system.rowLength;
  if (equalTo.length != n) {
    throw new ArgumentError("equalTo must be a vector of length $n");
  }
  
  Matrix mat = new Matrix.from(system);
  Matrix v   = equalTo.asColumnMatrix();
  
  //Converts the matrix, in upper triangular form in place
  //Every action performed on a row of m will also be performed
  //on the corresponding row of v.
  toUpperTriangular(Matrix m) {
    //Subtract the row at j from the row at i
    void subtractRow(int i, int j) {
      mat[i] = mat[i] - mat[j];
      v[i] = v[i] - v[j];
    }
    //Multiply the row at i by a constant amount
    void multiplyRowBy(int i, num amt) {
      mat.rows[i] = mat.rows[i].scaledBy(amt);
      v.rows[i] = v.rows[i].scaledBy(amt);
    }
    
    void swapRows(int i, int j) {
      var tmp = new Array.from(mat[i]);
      var vtmp = v[i];
      mat[i] = mat[j]; v[i] = v[j];
      mat[j] = tmp;    v[j] = vtmp;
    }
    
    //Perform the elimination using the pivot row i
    void eliminate(int pivotRow) {
      for (int i in range(pivotRow + 1, n)) {
        //Scale the row by a factor which makes it equal
        //to pivotRow at column pivotRow
        final pivotFactor = mat[pivotRow][pivotRow] / mat[i][pivotRow];
        multiplyRowBy(i, pivotFactor);
        subtractRow(i, pivotRow);
        assert(mat[i][pivotRow] == 0.0);
      }
    }
    
    //Finds the largest element at the position pivotColumn
    //in the rows below the row pivotColumn
    int findPivotRowIndex(int pivotColumn) {
      var maxIndex = range(pivotColumn + 1, n)
           .fold(mat[pivotColumn][pivotColumn], 
               (r, i) => mat[i][pivotColumn] > mat[r][i] ? i : r);
    }
    
    for (var i in range(n)) {
      int pivotRow = findPivotRowIndex(i);
      swapRows(pivotRow, i);
    }
  }
  
  
  
}

class Matrix<T extends num> {
  /**
   * The number of [:rows:] in `this`
   */
  final int rowLength;
  /**
   * The number of [:columns:] in `this`
   */
  final int columnLength;
  final Array<Vector<T>> _rows;
  
  /**
   * Creates a new `n x m` matrix
   * If [:fill:] is not null, the items of the matrix
   * will be all set to [:fill:]
   */
  Matrix(int n, int m, [T fill]) :
    rowLength = n,
    columnLength = n,
    _rows = new Array<Vector<T>>(n) {
    for (var i in range(n)) {
      _rows[i] = new Array<T>(m);
      _rows[i].setAll(0, new Iterable.generate(m, (i) => fill));
    }
  }
  
  /**
   * returns a copy of [:mat:]
   */
  factory Matrix.from(Matrix<T> mat) {
    Matrix newMat = new Matrix<T>(mat.rowLength, mat.columnLength);
    newMat.rows = mat.rows;
    return newMat;
  }
  
  /**
   * Returns the transpose matrix of [:mat:]
   */
  factory Matrix.transpose(Matrix<T> mat) {
    Matrix newMat = new Matrix<T>(mat.columnLength, mat.rowLength);
    newMat.rows = mat.columns;
    return newMat;
  }
  
  /**
   * Returns a view of the rows of the matrix.
   * 
   */
  Array<Vector<T>> get rows {
    Array<Vector<T>> rows = new Array<Vector<T>>(rowLength);
    for (var i in range(rowLength)) {
      rows[i] = new Vector<T>._from(this[i]);
    }
    return rows;
  }
  void set rows(Array<Vector<T>> values) {
    if (values.length != rowLength) {
      throw new StateError("There must be $rowLength vectors in values");
    }
    if (values.any((v) => v.length != columnLength)) {
      throw new StateError("Every vector in values must be of length $columnLength");
    }
    for (var i in range(rowLength)) {
      for (var j in range(columnLength)) {
        this[i][j] = values[i][j];
      }
    }
  }
  
  
  
  Array<Vector<T>> get columns {
    Array<Vector<T>> columns = new Array<Vector<T>>(columnLength);
    for (var j in range(columnLength)) {
      columns[j] = new Vector<T>(rowLength);
      for (var i in range(rowLength)) {
        columns[j][i] = this[i][j];
      }
    }
    return columns;
  }
  void set columns(Array<Vector<T>> values) {
    if (values.length != columnLength) {
      throw new RangeError(
          "values must be an array of length $columnLength");
    }
    if (values.any((r) => r.length != rowLength)) {
      throw new RangeError(
          "Every array in values must be of length $rowLength");
    }
    for (var i in range(rowLength)) {
      for (var j in range(columnLength)) {
        this[i][j] = values[j][i];
      }
    }
  }
  
  /**
   * Considers the (n +1 x n + 1) matrix as a system of equations 
   *
   *    | mat11 . . . mat0n | | x1 |   | v1 |
   *    |   .   .       .   | | .  |   | .  |
   *    |   .     .     .   | | .  | = | .  |
   *    |   .       .   .   | | .  |   | .  |
   *    | mat1n . . . matnn | | xn |   | vn |
   *    
   * And performs gaussian elimination on the matrix until the matrix
   * is in echelon form.
   * 
   * The solution will be returned as a vector.
   * 
   * NOTE: The elimination is performed in-place for efficiency.
   */
  Vector<T> solve(Vector<T> v) {
    if (!isSquare) {
      throw new StateError("Cannot solve non-square matrix");
    }
    if (v.length != rowLength) {
      throw new StateError("Vector length must be $rowLength");
    }
    //Swap the positions of the rows i and j in the matrix mat
    void swapRows(Matrix<T> mat, i, j) {
      var t = mat.rows[i];
      mat[i] = mat[j];
      mat[j] = t;
    }
    
    Matrix<T> vmat = v.asColumnMatrix();
    final n = rowLength;
    
    //Find the row with the maximum element at the index i
    //in the rows after i.
    int maxElementAtIdx(int i) =>
        range(i + 1, n)
        .fold(i, 
            (maxRow, j) => this[j][i].abs() > maxRow.abs() ? j : maxRow);
    
    //Eliminate the values in rows below i 
    int pivot(int pivotRow) {
      for (var i in range(pivotRow + 1, n)) {
        final rowFactor = this[i][pivotRow] / this[pivotRow][pivotRow];
        for (var j in range(n - 1, pivotRow - 1)) {
          this[i][j] = this[i][j] - this[pivotRow][j] * rowFactor;
        }
        //And eliminate the value in vmat too
        vmat[i][0] = vmat[i][0] - vmat[pivotRow] * rowFactor;
      }
    }
    
    for (var i in range(n)) {
      var maxElementRow = maxElementAtIdx(i);
      if (this[maxElementRow][i] == 0.0) {
        //matrix has no solution
        return null;
      }
      swapRows(this, i, maxElementRow);
      swapRows(vmat, i, maxElementRow);
      
      pivot(i);
    }
    
    //this is now in upper-triangle form
    //The solution vector is available via substitution
    Vector<T> solution = new Vector<T>.ofLength(n);
    
    for (int j in range(n-1, -1)) {
      var t = 0.0;
      for (int k in range(j + 1, n)) {
        t += this[j][k] * solution[k];
      }
      solution[j] = (vmat[j][0] / this[j][j]);
    }
    return solution;
  }

  
  /**
   * Tests whether `this` is a square matrix
   */
  bool get isSquare => 
      rowLength == columnLength;
  
  /**
   * Returns the transpose of this matrix
   */
  Matrix<T> get transposed => 
      new Matrix<T>.transpose(this);
  
  /**
   * Returns the result of right multiplying `this`
   * by the vector [:v:]
   * 
   * Equivalent to:
   *    (this * v.asColumnMatrix())[0]
   *    
   * Throws a [StateError] if the length of the [Vector]
   * is not equal to the length of the 
   */
  Vector<T> multiplyVector(Vector<T> v) =>
      (this * v.asColumnMatrix())[0];
  
  /**
   * Get the row at index [:i:]
   */
  Vector<T> operator[](int i) => _rows[i];
  void operator []=(int i, Vector<T> values) {
    if (values.length != columnLength) {
      throw new RangeError(
          "values must be an array of length $columnLength");
    }
    _rows[i].setAll(0, values);
  }
  
  /**
   * Returns the matrix sum of the two matrices.
   * Throws a [RangeError] if the argument matrix
   * does not have the same number of rows and columns
   * as `this`
   */
  Matrix<T> operator +(Matrix<T> mat) {
    if (mat.rowLength != rowLength 
        || mat.columnLength != columnLength) {
      throw new RangeError(
          "Matrix addition only defined on "
          "matrices of equal dimension");
    }
    Matrix<T> sum = new Matrix(rowLength, columnLength);
    for (var i in range(rowLength)) {
      for (var j in range(columnLength)) {
        sum[i][j] = this[i][j] + mat[i][j];
      }
    }
  }
  
  /**
   * Returns the matrix obtained by negating every
   * element of `this`
   */
  Matrix<T> operator -() {
    Matrix<T> negate = new Matrix(rowLength, columnLength);
    for (var i in range(rowLength)) {
      for (var j in range(columnLength)) {
        negate[i][j] = -this[i][j];
      }
    }
  }
  
  /**
   * Returns the matrix defined by adding `this`
   * to the negation of `mat`.
   */
  Matrix<T> operator -(Matrix<T> mat) {
    return this + (-mat); 
  }
  
  /**
   * Returns the matrix obtained by right multiplying
   * `this` by [:mat:].
   * 
   * To obtain the result of a matrix multiplied by a 
   * vector, you can use [:multiplyVector:]
   *      
   * Throws a [StateError] if [:mat.columnLength:] is not
   * equal to [:this.rowLength:]
   */
  Matrix<T> operator *(Matrix<T> mat) {
    if (this.rowLength != mat.columnLength) {
      throw new StateError(
          "Cannot multiply matrices. Expected a matrix with "
          "column length $rowLength");
    }
    Matrix<T> mult = new Matrix<T>(mat.rowLength, columnLength);
    for (var i in range(mat.rowLength)) {
      for (var j in range(columnLength)) {
        mult[i][j] = mat.rows[i] * columns[j];
      }
    }
    return mult;
  }
}
