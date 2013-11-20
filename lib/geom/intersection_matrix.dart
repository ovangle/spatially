library geom.intersection_matrix;

import 'package:range/range.dart';
import '../base/array.dart';

import 'dimension.dart' show DimensionRangeError, 
                             isDimensionNonEmpty, 
                             dimensionValueFromSymbol, 
                             dimensionSymbolFromValue;
import 'dimension.dart' as dim;
import 'location.dart' as loc;

/**
 * Models a *Dimensionally Extended Nine-Intersection Model (DE-91M)* matrix.
 * DE-91M matrices model the topographical relationship between two [Geometry]s
 * 
 * The class can also represent matrix patterns (eg. `"[T*T******]"`)
 * which are used for matching instances of DE-91M matrices.
 * 
 * Methods are provided to:
 * -- set and query the matrix
 * -- convert to and from the standard string representation
 * -- query the matrix to see if it matches a pattern string
 * 
 * For a full description of DE-91M matrices, see *OpenGIS Simple Features specification for SQL*
 * [0] Part 1: Common architecture.
 * 
 * [0](http://www.opengis.org/techno/specs.html)
 */
class IntersectionMatrix {
  
  Array<Array<int>> _matrix;
  
  void _init() {
    _matrix = new Array(3);
    for (var i in range(3)) {
      _matrix[i] = new Array(3);
      _matrix[i].fillRange(0, 3, dim.EMPTY);
    }
  }
  
  
  
  /**
   * A new [IntersectionMatrix] with every entry set to [:Dimension.FALSE:]
   */
  IntersectionMatrix() {
    _init();
  }
  
  IntersectionMatrix.copy(IntersectionMatrix other) {
    _init();
    this[loc.INTERIOR][loc.INTERIOR] = other[loc.INTERIOR][loc.INTERIOR];
    this[loc.INTERIOR][loc.BOUNDARY] = other[loc.INTERIOR][loc.BOUNDARY];
    this[loc.INTERIOR][loc.EXTERIOR] = other[loc.INTERIOR][loc.EXTERIOR];
    this[loc.BOUNDARY][loc.INTERIOR] = other[loc.BOUNDARY][loc.INTERIOR];
    this[loc.BOUNDARY][loc.BOUNDARY] = other[loc.BOUNDARY][loc.BOUNDARY];
    this[loc.BOUNDARY][loc.EXTERIOR] = other[loc.BOUNDARY][loc.EXTERIOR];
    this[loc.EXTERIOR][loc.INTERIOR] = other[loc.EXTERIOR][loc.INTERIOR];
    this[loc.EXTERIOR][loc.BOUNDARY] = other[loc.EXTERIOR][loc.BOUNDARY];
    this[loc.EXTERIOR][loc.EXTERIOR] = other[loc.EXTERIOR][loc.EXTERIOR];
  }
  
  /**
   * Create an [IntersectionMatrix] from the string of nine dimensional symbols
   * in row major order.
   * The pattern can only contain values from {F,0,1,2}, the wildcards T and *
   * are only valid in match patterns
   */
  IntersectionMatrix.fromPattern(String pattern) {
    _init();
    if (pattern.length != 9) {
      throw new ArgumentError("Invalid dimension pattern: $pattern");
    }
    for (var i in range(9)) {
      final dimSymbol = pattern.substring(i, i + 1);
      final dimValue = dim.dimensionValueFromSymbol(dimSymbol);
      _checkDimensionIsValid(dimValue);
      //We should only be inserting
      this[(i / 3).floor()][i % 3] = dimValue;
    }
  }
  
  /**
   * Returns an array containing copies of each row
   * in the matrix.
   */
  Array<Array<int>> get rows {
    Array<Array<int>> rows = new Array<Array<int>>(3);
    for (var i in range(3)) {
      rows[i] = new Array.from(this[i]);
    }
    return rows;
  }
  void set rows (Array<Array<int>> rowValues) {
    if (rowValues.length != 3) {
      throw new RangeError.range(3, 3, 3);
    }
    if (rowValues.any((r) => r.length != 3)) {
      throw new RangeError.range(3, 3, 3); 
    }
    for (var i in range(3)) {
      for (var j in range(3)) {
        this[i][j] = rowValues[i][j];
      }
    }
  }
  
  Array<Array<int>> get columns {
    Array<Array<int>> cols = new Array<Array<int>>(3);
    for (var i in range(3)) {
      cols[i] = new Array<int>(3);
      for (var j in range(3)) {
        cols[i][j] = this[j][i];
      }
    }
    return cols;
  }
  
  void set columns(Array<Array<int>> columnValues) {
    if (columnValues.length != 3) {
      throw new RangeError.range(3, 3, 3);
    }
    if (columnValues.any((r) => r.length != 3)) {
      throw new RangeError.range(3, 3, 3); 
    }
    for (var i in range(3)) {
      for (var j in range(3)) {
        this[i][j] = columnValues[j][i];
      }
    }
  }
  
  /**
   * Add an intersection matrix to this.
   * Intersection is defined by taking the maximum dimension value
   * of each position in the summand matrices.
   * The order of dimension values is {DIM_DONTCARE, DIM_TRUE, DIM_FALSE, 0, 1, 2}
   */
  void add(IntersectionMatrix im) {
    for(var i in range(3)) {
      for (var j in range(3)) {
        setIfLessThan(i, j, im[i][j]);
      }
    }
  }
  
  /**
   * Set the entry at (i, j) to [:value:], if the current value
   * at that index is less than [:value:].
   */
  void setIfLessThan(int i, int j, int value) {
    if (this[i][j] < value) {
      this[i][j] = value;
    }
  }
  
  IntersectionMatrix get transposed {
    var transposed = new IntersectionMatrix();
    transposed.rows = columns;
    return transposed;
  }

  Array<int> operator [](int i) => _matrix[i];
  
  bool operator ==(Object other) {
    if (other is IntersectionMatrix) {
      for (var i in range(3)) {
        for (var j in range(3)) {
          if (this[i][j] != other[i][j]) return false;
        }
      }
      return true;
    }
    return false;
  }
  
  int get hashCode {
    int hash = 7;
    for (var i in range(3)) {
      for (var j in range(3)) {
        hash = hash * 7 + this[i][j].hashCode;
      }
    }
    return hash;
  }
  
  /**
   * Tests if this matrix matches the pattern
   * for disjoint geometries (`FF*FF****`)
   */
  bool get isDisjoint => this[loc.INTERIOR][loc.INTERIOR] == dim.EMPTY
                      && this[loc.INTERIOR][loc.BOUNDARY] == dim.EMPTY 
                      && this[loc.BOUNDARY][loc.INTERIOR] == dim.EMPTY
                      && this[loc.BOUNDARY][loc.BOUNDARY] == dim.EMPTY;
  
  /**
   * `true` if [:isDisjoint:] is `false`, 
   * ie. the [Geometry]s related by this [IntersectionMatrix] intersect.
   */
  bool get isIntersects => !isDisjoint;
  
  /**
   * Tests whether the first geometry related by `this` is within the 
   * second geometry.
   * (ie. the matrix matches `T*F**F***`)
   */
  bool get isWithin => isDimensionNonEmpty(this[loc.INTERIOR][loc.INTERIOR])
                    && this[loc.INTERIOR][loc.EXTERIOR] == dim.EMPTY
                    && this[loc.BOUNDARY][loc.EXTERIOR] == dim.EMPTY;
  
  /**
   * Tests whether the first geometry related by `this` is within the
   * second geometry.
   * (ie. the matrix matches `T*****FF*`)
   */
  bool get isContains => isDimensionNonEmpty(this[loc.INTERIOR][loc.INTERIOR])
                      && this[loc.EXTERIOR][loc.INTERIOR] == dim.EMPTY
                      && this[loc.EXTERIOR][loc.BOUNDARY] == dim.EMPTY;
  
  
  /**
   * Tests whether the first geometry related by `this` covers the 
   * second geometry.
   * ie. the matrix matches one of:
   * -- `T*****FF*`
   * -- `*T****FF*`
   * -- `***T**FF*`
   * -- `****T*FF*`
   */
  bool get isCovers => isIntersects
                    && this[loc.EXTERIOR][loc.INTERIOR] == dim.EMPTY 
                    && this[loc.EXTERIOR][loc.BOUNDARY] == dim.EMPTY;
  
  /**
   * Tests whether the first geometry related by `this` is covered by
   * the second geometry
   * ie. the matrix matches one of:
   * -- `T*F**F***`
   * -- `*TF**F***`
   * -- `**FT*F***`
   * -- `**F*TF***`
   */
  bool get isCoveredBy => isIntersects
                       && this[loc.INTERIOR][loc.EXTERIOR] == dim.EMPTY
                       && this[loc.BOUNDARY][loc.EXTERIOR] == dim.EMPTY;
  
  /**
   * Tests whether the argument dimensions are equal and if the
   * first geometry related by `this` is topologically equal to the second
   * geometry,
   * ie. `this` matches the pattern `T*F**FFF*`
   * 
   * Note: As per JTS, this differs from the specification (`TFFFTFFFT`), 
   * since that would specify that two identical POINTs are not equal, 
   * which is undesirable behaviour.
   * The pattern here will compute equality in this situation.
   */
  bool isEquals(int dimensionOfGeometryA, int dimensionOfGeometryB) {
    _checkDimensionIsValid(dimensionOfGeometryA);
    _checkDimensionIsValid(dimensionOfGeometryB);
    if (dimensionOfGeometryA == dimensionOfGeometryB) {
      return isDimensionNonEmpty(this[loc.INTERIOR][loc.INTERIOR])
          && this[loc.INTERIOR][loc.EXTERIOR] == dim.EMPTY
          && this[loc.BOUNDARY][loc.EXTERIOR] == dim.EMPTY
          && this[loc.EXTERIOR][loc.INTERIOR] == dim.EMPTY
          && this[loc.EXTERIOR][loc.BOUNDARY] == dim.EMPTY;
    } else {
      return false;
    }
  }
  
  /**
   * Tests whether the first geometry related by `this` overlaps
   * the second geometry. The `overlaps` predicate is only valid for
   * geometries of equal dimension and the matrix matches
   * -- `T*T*****T` for A/A and P/P
   * -- `1*T*****T` for L/L
   */
  bool isOverlaps(int dimensionOfGeometryA, int dimensionOfGeometryB) {
    _checkDimensionIsValid(dimensionOfGeometryA);
    _checkDimensionIsValid(dimensionOfGeometryB);
    if ((dimensionOfGeometryA == dim.POINT && dimensionOfGeometryB == dim.POINT)
        || (dimensionOfGeometryA == dim.AREA && dimensionOfGeometryB == dim.AREA)) {
      return isDimensionNonEmpty(this[loc.INTERIOR][loc.INTERIOR])
          && isDimensionNonEmpty(this[loc.INTERIOR][loc.EXTERIOR])
          && isDimensionNonEmpty(this[loc.EXTERIOR][loc.EXTERIOR]);
    }
    if (dimensionOfGeometryA == dim.LINE && dimensionOfGeometryB == dim.LINE) {
      return this[loc.INTERIOR][loc.INTERIOR] == dim.LINE
          && isDimensionNonEmpty(this[loc.INTERIOR][loc.EXTERIOR])
          && isDimensionNonEmpty(this[loc.EXTERIOR][loc.INTERIOR]);
    }
    return false;
  }
  
  /**
   * `true` if this [IntersectionMatrix] matches
   * `"FT******"`, `"F**T*****"` or `"F***T****"`.
   * 
   * [:dimensionOfGeometryA:] is the dimension of the first [Geometry]
   * related
   * [:dimensionOfGeometryB:] is the dimension of the second [Geometry] 
   * related by `this`.
   * 
   * Returns `true` if the [Geometries] related by `this`.
   * Unless both geometries have dimension [:DIM_POINT:], in which
   * case returns `false`.
   */
  bool isTouches(int dimensionOfGeometryA, int dimensionOfGeometryB) {
    _checkDimensionIsValid(dimensionOfGeometryA);
    _checkDimensionIsValid(dimensionOfGeometryB);
    if (dimensionOfGeometryA > dimensionOfGeometryB) {
      //relation is symmetrical
      return isTouches(dimensionOfGeometryB, dimensionOfGeometryA);
    }
    if (dimensionOfGeometryA != dim.POINT || dimensionOfGeometryB != dim.POINT) {
      return this[loc.INTERIOR][loc.BOUNDARY] == dim.EMPTY
          && (isDimensionNonEmpty(this[loc.INTERIOR][loc.BOUNDARY])
              || isDimensionNonEmpty(this[loc.BOUNDARY][loc.INTERIOR])
              || isDimensionNonEmpty(this[loc.BOUNDARY][loc.BOUNDARY]));
    } else {
      return false;
    }
  }
  
  /**
   * Tests whether this [Geometry] crosses the specified geometry.
   * 
   * The `crosses` predicate has the following equivalent definitions.
   * -- The geometries have some but not all interior points in common
   * -- The DE-91M Intersection Matrix for the two geometries is:
   *  -- T*T****** (for P/L, P/A and L/A situations)
   *  -- T*****T** (for L/P, L/A and A/L situations)
   *  -- 0******** (for L/L situations)
   *
   * For any other combination of dimensions this predicate returns `false`.
   * As in JTS, this predicate has been extended to cover L/P, A/P and A/L situations
   * in addition to the situations defined by SFS, so the relation is symmetric.
   * 
   * [:dimensionOfGeometryA:] is the dimension of the first [Geometry] related by `this`.
   * [:dimensionOfGeometryB:] is the dimension of the second [Geometry] related by `this`.
   */
  bool isCrosses(int dimensionOfGeometryA, int dimensionOfGeometryB) {
    _checkDimensionIsValid(dimensionOfGeometryA);
    _checkDimensionIsValid(dimensionOfGeometryB);
    if ((dimensionOfGeometryA == dim.POINT && dimensionOfGeometryB == dim.LINE)
        || (dimensionOfGeometryA == dim.POINT && dimensionOfGeometryB == dim.AREA)
        || (dimensionOfGeometryA == dim.LINE && dimensionOfGeometryB == dim.AREA)) {
      return isDimensionNonEmpty(this[loc.INTERIOR][loc.INTERIOR])
          && isDimensionNonEmpty(this[loc.INTERIOR][loc.EXTERIOR]);
    }
    if ((dimensionOfGeometryA == dim.LINE && dimensionOfGeometryB == dim.POINT)
        || (dimensionOfGeometryA == dim.AREA && dimensionOfGeometryB == dim.POINT)
        || (dimensionOfGeometryA == dim.AREA && dimensionOfGeometryB == dim.LINE)) {
      return isDimensionNonEmpty(this[loc.INTERIOR][loc.INTERIOR])
          && isDimensionNonEmpty(this[loc.EXTERIOR][loc.EXTERIOR]);
    }
    if (dimensionOfGeometryA == dim.LINE && dimensionOfGeometryB == dim.LINE) {
      return this[loc.INTERIOR][loc.INTERIOR] == dim.POINT;
    }
    return false;
  }
  
  /**
   * Matches the `this` against an arbitrary dimensionPattern 
   * (a 9 character [String] consisting of values from `[T,F,*,0,1,2])
   */
  bool matches(String dimensionPattern) {
    /**
     * Test if the dimension value satisfies the dimension symbol.
     */
    bool _dimensionMatches(int actualDimensionValue, String requiredDimensionSymbol) {
      switch (dimensionValueFromSymbol(requiredDimensionSymbol)) {
        case dim.DONTCARE:
          //matches everything
          return true;
        case dim.EMPTY:
          return actualDimensionValue == dim.EMPTY;
        case dim.NONEMPTY:
          return isDimensionNonEmpty(actualDimensionValue);
        case dim.POINT:
          return actualDimensionValue == dim.POINT;
        case dim.LINE:
          return actualDimensionValue == dim.LINE;
        case dim.AREA:
          return actualDimensionValue == dim.AREA;
      }
    }
    if (dimensionPattern.length != 9) {
      throw new ArgumentError("Dimension patterns must have exactly nine symbols\n"
                              "\tGot: $dimensionPattern");
    }
    for (var i in range(3)) {
      for (var j in range(3)) {
        var symbolIndex = 3 * i + j;
        var requiredSymbol = dimensionPattern.substring(symbolIndex, symbolIndex + 1);
        if (!_dimensionMatches(this[i][j], requiredSymbol)) {
          return false;
        }
      }
    }
    return true;
  }
  
  String toString() {
    StringBuffer sBuf = new StringBuffer();
    for (var i in range(3)) {
      for (var j in range(3)) {
        sBuf.write(dimensionSymbolFromValue(this[i][j]));
      }
    }
    return sBuf.toString();
  }
}

/**
 * Throw a [DimensionRangeError] if [dimensionOfGeometry] is not
 * a valid dimensional value
 */
void _checkDimensionIsValid(int dimensionOfGeometry) {
  switch(dimensionOfGeometry) {
    case dim.EMPTY:
    case dim.POINT:
    case dim.LINE:
    case dim.AREA:
      return;
    default:
      throw new DimensionRangeError.actual(dimensionOfGeometry);
  }
}