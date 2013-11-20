part of algorithm.metric;

/**
 * An algorithm for computing a distance metric which
 * approximates the hausdorff metric between two [Geometry]s
 * 
 * The [:hausdorffMetric:] of two geometries is defined to be
 * the greatest distance between any point in the first geometry
 * to the closest point in the second geometry.
 *            
 * It is an approximation to the hausdorff distance, with
 * the guarantee that 
 *     discreteHausdorffMetric(g1,g2) <= hausdorfMetric(g1,g2)
 *     
 * It takes an optional argument [:densify:], which must be a 
 * double in the range (0.0, 1.0]. The metric matches the 
 * hausdorff metric between the two geometries in the limit densify -> 0
 * but the default of 1.0 is suitable for a large subset of useful cases,
 * for example:
 *  -- When calculating the distance between [Linestring]s which are 
 *     approximately parallel and equal in length.
 *  -- Testing similarity of [Geometry]s
 */
const Metric discreteHausdorffMetric = _hausdorffDistance;

double _hausdorffDistance(Geometry g1, Geometry g2, [double densify = 1.0]) {
  if (densify <= 0.0 || densify > 1.0) {
    throw new RangeError("densify must be in the range (0.0, 1.0]");
  }
  throw 'NotImplemented';
  
}