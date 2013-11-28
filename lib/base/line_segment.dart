library base.line_segment;

import 'dart:math' as math;

import 'coordinate.dart';
import 'envelope.dart';

/**
 * Represents the [LineSegment] between two [Coordinate]s
 */
class LineSegment {
  final Coordinate start;
  final Coordinate end;
  
  LineSegment(Coordinate this.start, Coordinate this.end);
  
  Envelope get envelope =>
      new Envelope.fromCoordinates(start, end);
  
  /**
   * The projection of the [LineSegment] along the x-axis
   * Equivalent to end.x - start.x
   */
  double get projx => end.x - start.x;
  /**
   * The projection of the [LineSegment] along the y-axis.
   * Equivalent to end.y - start.y
   */
  double get projy => end.y - start.y;
  
  /**
   * The angle that this [LineSegment] makes with the
   * positive x-axis, as a [double] in the range (-PI,PI]
   */
  double get angle =>
      math.atan2(projy, projx);
  
  /**
   * A [LineSegment] from [end] to [start].
   */
  LineSegment get reversed =>
      new LineSegment(end, start);
  
  /**
   * A new [LineSegment] translated by [:dx:] along the
   * x-axis and [:dy:] units along the y-axis
   */
  LineSegment translated(double dx, double dy) =>
      new LineSegment(start.translated(dx, dy),
                      end.translated(dx, dy));
  
}

