part of geom.coordinate_sequence;

/**
 * Creates a [CoordinateSequence] with all coordinates
 * initialized to a default value.
 * [:dimension:] is the number of dimensions on the created
 * sequence.
 */
typedef CoordinateSequenceFactory(int length, [int dimension]);