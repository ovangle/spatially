/**
 * Implemtation of basic geometry algorithms
 * using [longdouble] arithmetic to ensure robustness
 */
library algorithm.cg_algorithms_ld;

import 'package:spatially/base/longdouble.dart';
import 'package:spatially/base/coordinate.dart';

/**
 * The index of the direction of the point [:q:] relative
 * to the vector defined by [:c1:] -> [:c2:]
 * 
 * Returns 
 * `1` if the point is counter-clockwise (left) of [:c1:]->[:c2:]
 * `-1` if the point is clockwise (right) of [:c1:]->[:c2:]
 * `0` if the point is collinear with [:c1:]->[:c2:]
 */
int orientationIndex(Coordinate c1, Coordinate c2, Coordinate q) {
  longdouble c1x = new longdouble(c1.x);
  longdouble c1y = new longdouble(c1.y);
  longdouble c2x = new longdouble(c2.x);
  longdouble c2y = new longdouble(c2.y);
  longdouble qx  = new longdouble(q.x);
  longdouble qy  = new longdouble(q.y);
  
  final dx1 = c2x - c1x;
  final dy1 = c2y - c1y;
  
  final dx2 = qx - c2x;
  final dy2 = qy - c2y;
  
  return ((dx1 * dy2) - (dy1 * dx2)).compareToNum(0);
}
