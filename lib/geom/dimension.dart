library geom.dimension;

/**
  * Dimensional value of a point (0)
  */
const int POINT = 0;

/**
 * Dimensional value of a curve (1)
 */
const int LINE = 1;
  
/**
 * Dimensional value of a surface (2)
 */
const int AREA = 2;

/**
 * Dimensional value of the empty geometry
 * Represented by `F` in a dimension pattern
 */
const int EMPTY = -1;
  
/**
 * Dimensional value for non-empty geometries
 * Represented by `T` in a dimension pattern
 */
const int NONEMPTY = -2;
  
/**
 * Dimensional value for any dimension
 * Represented by `*` in a dimension pattern
 */
const int DONTCARE = -3;


/**
 * The values DIM_POINT, DIM_LINE and DIM_AREA should all be considered
 * values of DIM_TRUE
 */
bool isDimensionNonEmpty(int dimensionValue) {
  switch(dimensionValue) {
    case NONEMPTY:
    case POINT:
    case LINE:
    case AREA:
      return true;
    case EMPTY:
    case DONTCARE:
      return false;
    throw new ArgumentError("Unrecognised dimensional value: $dimensionValue");
  }
}


  
/**
 * Get the symbolic representation of a dimensional value
 */
String dimensionSymbolFromValue(int dimensionalValue) {
  switch(dimensionalValue) {
    case EMPTY: return 'F';
    case NONEMPTY: return 'T';
    case DONTCARE: return '*';
    case POINT: return '0';
    case LINE: return '1';
    case AREA: return '2';
    default:
      throw new ArgumentError("Unknown dimensional value: $dimensionalValue");
  }
}
  
/**
 * Convert the unicode code point symbol to its integer value
 */
int dimensionValueFromSymbol(String dimensionalSymbol) {
  switch(dimensionalSymbol.toUpperCase()) {
    case 'F': return EMPTY;
    case 'T': return NONEMPTY;
    case '*': return DONTCARE;
    case '0': return POINT;
    case '1': return LINE;
    case '2': return AREA;
    default:
      throw new ArgumentError("Unknown dimensional symbol: $dimensionalSymbol");
  }
}



class DimensionRangeError extends RangeError {
  DimensionRangeError.actual(int dim) 
    : super("A geometry's dimension must be one of "
            " 0 (POINT), 1 (CURVE) or 2 (PLANAR).\n"
            "\tGot: $dim");
}