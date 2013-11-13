part of geom.coordinate_sequence;

//Utility functions for dealing with [CoordinateSequence]s

/**
 * Expand the [Envelope] to contain all the [Coordinate] values
 * in this sequence.
 * Override to optimize the envelope calculation of the [GeometrySequence]
 */
Envelope _expandEnvelope(CoordinateSequence coords, Envelope env) {
  var envCopy = new Envelope.copy(env);
  for (var c in coords) {
    envCopy.expandToCoordinate(c);
  }
  return envCopy;
}

/**
 * Tests whether the [CoordinateSequence] forms a valid [LinearRing]
 * by checking the sequence length and closure.
 * Self-intersection is not checked.
 */
bool _coordinateSequenceIsRing(CoordinateSequence coords) =>
    coords.isEmpty || (coords.length > 3 && coords.first == coords.last);

/**
 * Returns a [CoordinateSequence] which forms a valid ring,
 * creating a new sequence from the given [CoordinateSequenceFactory] [:fact:]
 * if required.
 * 
 * If already a valid ring, the [CoordinateSequence] is copied and returned
 */
CoordinateSequence _coordinateSequenceAsValidRing(CoordinateSequence coords, CoordinateSequenceFactory fact) {
  createClosedRing(int newLength) {
    assert(newLength > coords.length);
    CoordinateSequence newSeq = fact(coords.length, coords.dimension);
    newSeq.setRange(0, coords.length, coords);
    //fill remaining coordinates with start point
    for (var i in range(coords.length, newLength)) {
      newSeq[i] = coords.first;
    }
    return newSeq;
  }
  if (_coordinateSequenceIsRing(coords)) return coords.clone();
  return createClosedRing(coords.length > 3 ? (coords.length + 1) : 4);
}

/**
 * Extend this to the given length, filling coordinates with the the current
 * endpoint until the new size is reached.
 * If [:newLength:] is less than the length of the [CoordinateSequence], the 
 * the sequence will be truncated to the given length.
 * If [:coords:] is an empty sequence, a [StateError] is thrown
 */
CoordinateSequence _coordinateSequenceExtended(CoordinateSequence coords, CoordinateSequenceFactory fact, int newLength) {
  if (coords.isEmpty) {
    throw new StateError("Cannot extend empty CoordinateSequence");
  }
  CoordinateSequence newSeq = fact(newLength, coords.dimension);
  int n = math.min(coords.length, newLength);
  newSeq.setRange(0, n, coords);
  if (n < newLength) {
    //fill remaining coordinates with endpoint
    for (var i = n;i<newLength;i++) {
      newSeq.fillRange(n, newLength, coords.last);
    }
  }
  return newSeq;
}


/**
 * A [Comparator] for comparing [CoordinateSequences] up to the given [:dimension:]
 * If [:coordComparator:] is provided, will be used to compare the [Coordinate]s, 
 * otherwise defaults to the natural lexicographic ordering of [Coordinate]s
 * in 2 dimensions.
 */
Comparator<CoordinateSequence> coordinateSequenceComparator(int dimension, 
                                                            [Comparator<Coordinate> coordComparator]) {
  if (coordComparator == null) {
    coordComparator = dimensionalComparator(dimension);
  }
  int compare(CoordinateSequence coords1, CoordinateSequence coords2) {
    int dim1 = coords1.dimension;
    int dim2 = coords2.dimension;
    int minDim = math.min(dim1, dim2);
    
    bool dimlimited = (dimension < minDim);
    if (dimlimited) {
      minDim = dimension;
    } else {
      if (dim1 < dim2) return -1;
      if (dim1 > dim2) return 1;
    }
    
    for (var i in range(math.min(coords1.length, coords2.length))) {
      var cmp = coordComparator(coords1[i], coords2[i]);
      if (cmp != 0) return cmp;
    }
    if (coords1.length < coords2.length) return -1;
    if (coords1.length > coords2.length) return 1;
    return 0;
  }
  return compare;
}