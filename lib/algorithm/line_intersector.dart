library algorithm.line_intersector;

/** The segments do not intersect */
const int NO_INTERSECTION         = 0;
/* The segments intersect at a single point */
const int POINT_INTERSECTION      = 1;
/** The segments intersect at a line segment */
const int COLLINEAR_INTERSECTION  = 2;

/**
 * Compute the "edge distance" of an intersection point along 
 * a segment. The edge distance is a metric of the point
 */