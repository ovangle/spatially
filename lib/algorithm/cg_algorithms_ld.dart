/**
 * Implemtation of basic geometry algorithms
 * using [longdouble] arithmetic to ensure robustness
 */
library algorithm.cg_algorithms_ld;

import 'package:longdouble/longdouble.dart';
import 'package:spatially/base/coordinate.dart';
import 'package:spatially/base/line_segment.dart';

/**
 * The index of the direction of the point [:q:] relative
 * to the vector defined by [:c1:] -> [:c2:]
 * 
 * Returns 
 * `1` if the point is counter-clockwise (left) of [:c1:]->[:c2:]
 * `-1` if the point is clockwise (right) of [:c1:]->[:c2:]
 * `0` if the point is collinear with [:c1:]->[:c2:]
 */
int orientationIndex(LineSegment lseg, Coordinate q) {
  longdouble start_x = new longdouble(lseg.start.x);
  longdouble start_y = new longdouble(lseg.start.y);
  longdouble end_x = new longdouble(lseg.end.x);
  longdouble end_y = new longdouble(lseg.end.y);
  longdouble qx  = new longdouble(q.x);
  longdouble qy  = new longdouble(q.y);
  
  final dx1 = start_x - end_x;
  final dy1 = start_y - end_y;
  
  final dx2 = qx - end_x;
  final dy2 = qy - end_y;
  
  return ((dx1 * dy2) - (dy1 * dx2)).compareToNum(0);
}
