library geom.coordinate_sequence;

import 'dart:math' as math;

import 'package:spatially/base/array.dart';
import 'package:spatially/base/coordinate.dart';
import 'package:quiver/iterables.dart';

import 'package:spatially/base/envelope.dart';

part 'src/coordinate_sequence/factory.dart';
part 'src/coordinate_sequence/utils.dart';
//Default implementation
part 'src/coordinate_sequence/defaults.dart';


/**
 * The internal representation of coordinates inside a [Geometry].
 * Allows storing of coordinates in something other than the immutable
 * [Coordinate] class provided by [spatially].
 * 
 * Implementing a custom [Coordinate] storage structure requires implementing
 * the [CoordinateSequence] class and providing a [CoordinateSequenceFactory]
 * to the [GeometryFactory] responsible for creating geometries.  
 */
abstract class CoordinateSequence implements Array<Coordinate>, Comparable<CoordinateSequence> {
  /**
   * Standard ordinate index values
   */
  static const int X = 0;
  static const int Y = 1;
  static const int Z = 2;
  static const int M = 3;
  
  /**
   * The number of ordinates in each [Coordinate] in the sequence
   */
  int get dimension;

  /**
   * Get the ordinate at [:ordinateIndex:] of the [i]th element of this sequence
   */
  double getOrdinate(int i, int ordinateIndex);
  /**
   * Set the ordinate at [:ordinateIndex:] of the [:i:]th element of this sequence.
   */
  void setOrdinate(int i, int ordinateIndex, double value);
  
  /**
   * Returns the values for a given ordinate between [:start:] and [:end:]
   */
  Iterable<double> getOrdinateRange(int start, int end, int ordinateIndex);
  
  /**
   * Create a deep copy of the [CoordinateSequence];
   */
  CoordinateSequence clone();
  
  /**
   * Creates a [CoordinateArray] containing the coordinates
   * in `this`. 
   */
  Array<Coordinate> toArray();
}





