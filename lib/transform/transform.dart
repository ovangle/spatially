library transform;

import 'package:spatially/geom/base.dart';

/**
 * # Affine Transformations of [Geometry]s in the 2d cartesian plane
 *
 * An affine transformation is a mapping of the 2d plane onto itself
 * ia a series of transformations of the following basic types
 * -- Reflection through a line
 * -- Rotation about the origin
 * -- Scaling relative to the origin
 * -- Shearing along the x and y axes
 * -- Translation
 *
 * In general, affine transformations preserve straightness and parallel lines
 * but not distance or shape.
 *
 * An affine transformation can be represented by a 3x3 matrix
 * in the following form
 * 
 *          |  m00  m01  m02 |
 *     T =  |  m10  m11  m12 |
 *          |   0    0    1  |
 *          
 * A coordinate P=(x,y) can be transformed by the transformation
 * matrix via right-multiplaction
 * 
 *     P' = T * P
 *     
 * Affine transformations can also be composed using matrix
 * multiplication, which is not commutative
 *
 * Some affine tranformations are invertible.
 */


/**
 * [AffineTransform] represents a generic 2d affine transform
 */
class AffineTransform {
  
}
