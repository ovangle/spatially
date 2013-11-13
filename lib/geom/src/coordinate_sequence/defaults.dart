part of geom.coordinate_sequence;

/**
 * Default implementation of the [CoordinateSequence] interface
 * is just an [Array] of [Coordinate]s.
 */
class DefaultCoordinateSequence extends Array<Coordinate> implements CoordinateSequence {
  static CoordinateSequenceFactory factory = (int length, [int dimension]) => new DefaultCoordinateSequence(length, dimension);

  final int dimension;
 
  DefaultCoordinateSequence(int length, [int this.dimension = 2]) : super(length);
  
  DefaultCoordinateSequence.from(Iterable<Coordinate> coords) : 
    super.from(coords),
    dimension = 2;
  
  double getOrdinate(int index, int ordinateIndex) =>
      this[index].getOrdinate(ordinateIndex);
  
  void setOrdinate(int index, int ordinateIndex, double value) =>
      this[index].setOrdinate(ordinateIndex, value);
  
  Iterable<double> getOrdinateRange(int start, int end, int ordinateIndex) =>
      getRange(start, end).map((c) => c.getOrdinate(ordinateIndex));
  
  CoordinateSequence clone() =>
      new DefaultCoordinateSequence.from(map((c) => new Coordinate.copy(c)));

  int compareTo(CoordinateSequence coords) =>
      forwardComparator(this, coords);
  
  Array<Coordinate> toArray() => 
      new Array<Coordinate>.from(this);
}