part of base.coordinate;

// Utility methods for dealing with Array<Coordinate>s   
/**
 * Tests whether the [CoordinateArray] forms a ring,
 * by checking its [:length:] and closure.
 * 
 * Self-intersection is not checked
 */
bool isRing(Array<Coordinate> coords) =>
    coords.isEmpty || (coords.length >= 4 && coords.first == coords.last);

/**
 * The minimum [Coordinate] in the [CoordinateArray], using
 * the default lexicographic ordering on [Coordinate]s
 * 
 * If the [CoordinateArray] is empty, returns
 *  `(double.INFINITY, double.INFINITY)`
 */
Coordinate minCoordinate(Array<Coordinate> coords) => 
    coords.fold(
      new Coordinate(double.INFINITY, double.INFINITY),
      (min, coord) => min < coord ? min : coord);

/**
 * The maximum [Coordinate] in the [CoordinateArray], using
 * the default lexicographic ordering on [Coordinate]s
 * 
 * If the [CoordinateArray] is empty, returns
 *  `(double.NEGATIVE_INFINITY, double.NEGATIVE_INFINITY)`
 */
Coordinate maxCoordinate(Array<Coordinate> coords) =>
  coords.fold(
      new Coordinate(double.NEGATIVE_INFINITY, double.NEGATIVE_INFINITY),
      (max, coord) => max > coord ? max : coord);

  
/**
 * Tests whether the [CoordinateArray] has two consecutive [Coordinate]s
 * which compare equal
 */
bool hasRepeatedCoordinates(Array<Coordinate> coords) => 
    range(1,coords.length).any((i) => coords[i] == coords[i-1]);

/**
 * Returns a new [CoordinateArray], with all repeated [Coordinate]s
 * removed.
 * Since the [:length:] of the returned array will likely be different
 * to [:length:], the removal is not performed in place.
 */
Array<Coordinate> removeRepeatedCoordinates(Array<Coordinate> coords) {
  return new Array<Coordinate>.from(
      range(0, coords.length)
          .where((i) => i == 0 || coords[i] != coords[i - 1])
          .map((i) => coords[i])
  );
}
  
/**
 * Collapses a [CoordinateArray], removing all of it's null elements
 */
Array<Coordinate> removeNullCoordinates(Array<Coordinate> coords) =>
    new Array<Coordinate>.from(coords.where((c) => c != null));

/**
 * Shifts the positions of coordinates until [:coord:] is the 
 * first element of `this`.
 * The scroll is performed in-place on the array.
 */
void scrollCoordinates(Array<Coordinate> coords, Coordinate c) {
  int i = coords.indexOf(c);
  final coordsBefore = coords.getRange(0, i);
  final coordsAfter = coords.getRange(i, coords.length);
  
  coords.setRange(0, coordsAfter.length, coordsAfter);
  coords.setRange(coordsAfter.length, coords.length, coordsBefore);
}

/**
* Returns an integer representing the direction in which
* the [Coordinate]s in the array increase according to their
* natural ordering.
* 
* If a positive integer is returned, the start of the array
* is "smaller" than the end of the array.
* A palindromic array is defined to travel in a positive direction
*/
int directionOfIncrease(Array<Coordinate> coords) {
  for (int i=0;i<coords.length / 2; i++) {
    var j = coords[coords.length - 1 - i];
    // skip equal on both ends
    var cmp = coords[i].compareTo(coords[j]);
    if (cmp != 0) return cmp;
  }
  //palindromic arrays are positive
  return 1;
}



/**
 * A [Comparator] which compares two coordinate arrays coordinate-wise
 */
Comparator<Array<Coordinate>> get forwardComparator {
  int compare(Array<Coordinate> coordArray1, Array<Coordinate> coordArray2) {
    int l1 = coordArray1.length;
    int l2 = coordArray2.length;
    int i=0;
    while (i < l1 && i < l2) {
      var cmp = coordArray1[i].compareTo(coordArray2[i]);
      if (cmp != 0) return cmp;
      i++;
    }
    if (i < l1) return 1;
    if (i < l2) return -1;
    return 0;
  }
  return compare;
}

/**
 * If two coordinate arrays are identical, but reversed, returns 0.
 * Otherwise return the result of ordering the arrays in the forward
 * direction
 */
Comparator<Array<Coordinate>> get bidirectionalComparator {
  bool isEqualReversed(Array<Coordinate> coords1, Array<Coordinate> coords2) {
    if (coords1.length != coords2.length) return false;
    var l = coords1.length;
    for (var i in range(l)) {
      var j = l - 1 - i;
      if (coords1[i] != coords2[j]) {
        return false;
      }
    }
    return true;
  }
  int compare(Array<Coordinate> coordArray1, Array<Coordinate> coordArray2) {
    
    var cmp = forwardComparator(coordArray1, coordArray2);
    if (cmp != 0 && isEqualReversed(coordArray1, coordArray2)) {
      return 0;
    }
    return cmp;
  }
  return compare;
}