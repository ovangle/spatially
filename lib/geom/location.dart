library geom.location;

/**
 * The location value for the interior of the geometry.
 * Also, the DE-91M row index of the interior of 
 * the first geometry and column index of the second
 * geometry.
 */
const int INTERIOR = 0;

/**
 * The location value for the boundary of a geometry.
 * Also, the DE-91M row index of the boundary of the
 * first geometry and column index of the boundary
 * of the second geometry
 */
const int BOUNDARY = 1;

/**
 * The location value for the exterior of the geometry.
 * Also, the DE-91M row index of the exterior of
 * the first geometry and column index of the second
 * geometry.
 */
const int EXTERIOR = 2;

/**
 * Uninitialized location value
 */
const int LOC_NONE = -1;

/**
 * Convert the given [:locationValue:] to its
 * symbolic representation.
 */
String toLocationSymbol(int locationValue) {
  switch(locationValue) {
    case EXTERIOR:
      return 'e';
    case BOUNDARY:
      return 'b';
    case INTERIOR:
      return '-';
    default:
      throw new ArgumentError("Unrecognised location value: $locationValue");
  }
}


