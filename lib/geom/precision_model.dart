library geom.precision_model;

import 'dart:math' as math;
import 'coordinate.dart';

/**
 * Specifies the precision model of the [Coordinate]s
 * in a [Geometry].
 * 
 * A [PrecisionModel] is a discrete grid of coordinates, which
 * individual [Coordinate]s are snapped. coordinates in geometries are 
 * assumed to be precise.
 * 
 * [:spatially:] supports three different types of [PrecisionModel]
 * -- FLOATING (default), full double precision floating point
 * -- FLOAING_SINGLE, single precision floating point
 * -- FIXED, a precision model with a fixed number of dcimal places.
 * 
 * A fixed precision model is specified by a scale factor. The scale factor
 * indicates the size of the grid which the numbers are rounded to.
 * Input coordinates are mapped to fixed coordinates vial
 *      pt.x = (input.x * scale).round() / scale
 *      pt.y = (input.y * scale).round() / scale
 *      
 * eg. The scale factor 1000 would specify coordinates fixed at the third decimal place,
 * and a scale factor of 0.001 would specifiy coordinates fixed to the nearest 1000.
 * 
 * Coordinates are represented internally using double precision digits.
 */
class PrecisionModel {
  
  static const String PREC_FLOATING = 'FLOATING';
  static const String PREC_FLOATING_SINGLE = 'FLOATING_SINGLE';
  static const String PREC_FIXED = 'FIXED';
  
  static double _log10(double num) =>
      math.log(num) / math.log(10);
  
  final String modelType;
  final double scale;
  
  /**
   * Create a [PrecisionModel] with the given type and scale.
   * If the type is not `PREC_FIXED`, the scale argument is ignored.
   * The scale defaults to `1.0`.
   */
  const PrecisionModel(String this.modelType, [double this.scale = 1.0]);
  
  int get maxSignificantDigits {
    switch(modelType) {
      case 'FLOATING':
        return 16;
      case 'FLOATING_SINGLE':
        return 6;
      case 'FIXED':
        return 1 + _log10(scale).ceil();
      default:
        throw new UnsupportedError("Unsupported model type: $modelType");
    }
  }
  
  double makePreciseDouble(double num) {
    //Don't change NaN
    if (num.isNaN) return num;
    switch (modelType) {
      case 'FLOATING': 
        return num;
      case 'FLOATING_SINGLE':
        //TODO: Need to investigate since dart does not provide a float type
        return num;
      case 'FIXED':
        return (num * scale).round() / scale;
      default:
        throw new UnsupportedError("Unsupported model type: $modelType");
    }
  }
  
  void makePreciseCoordinate(Coordinate c) {
    c.x = makePreciseDouble(c.x);
    c.y = makePreciseDouble(c.y);
  }
  
  String toString() {
    switch(modelType) {
      case 'FLOATING':
        return 'Floating';
      case 'FLOATING_SINGLE':
        return 'Floating-Single';
      case 'FIXED':
        return 'Fixed(Scale=$scale)';
    }
  }
  
}