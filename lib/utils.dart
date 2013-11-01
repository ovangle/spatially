library utils;

import 'dart:math';

degreesToRadians(double degrees) {
  return PI * degrees / 180.0;
}

radiansToDegrees(double radians) {
  return 180.0 * radians / PI;
}
/**
 * Compares two doubles within the given tolerance and 
 * returns
 *    -1 if d1 < d2
 *    0  if d1 == d2 within the given tolerance
 *    1  if d1 > d2.
 */
int compareDoubles(double d1, double d2, double tolerance) {
  if (d1 == d2) return 0;
  assert(tolerance != null && tolerance >= 0);
  var absDiff = (d1 - d2).abs();
  //If they are equal to within tolerance then they're equal
  //Otherwise there might be a problem comparing to 0.
  if (absDiff < tolerance) return 0;
  //Otherwise, scale tolerance by d2 and check the error
  if (absDiff < tolerance * d2.abs()) return 0;
  return (d1 < d2) ? -1 : 1;
}

bool isNull(dynamic obj) => obj == null;
bool isNotNull(dynamic obj) => obj != null;

/**
 * Code that should only be run in dart checked mode.
 */
void IFDEF_DEBUG(void runDebug()) {
  assert(() {
    runDebug();
    return true;
  }());
}

