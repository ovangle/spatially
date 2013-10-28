part of svg;

/**
 * An [SvgPoint] is a view of a given [Point] on the [SvgCanvas]
 */
class SvgPoint {
  final Point _p;
  
  SvgPoint(CanvasElement svgCanvas, Point this._p);
}