library math_ld;

import 'dart:math' as math;

import 'longdouble.dart';

/**
 * various mathematical operations for [longdouble] 
 * objects.
 */

const longdouble PI = 
    const longdouble(math.PI, 1.224646799353209e-16);

const longdouble E =
    const longdouble(math.E, 1.445646891729250158e-16);

longdouble min(longdouble dd1, longdouble dd2) =>
    dd1 >= dd2 ? dd2 : dd1;

longdouble max(longdouble dd1, longdouble dd2) =>
    dd1 >= dd2 ? dd1 : dd2;

/**
 * Raises a [longdouble] to a given integral [:exponent:].
 * In dart2js, where int is not yet implemneted, the value used will be the floor of 
 * the exponent value
 */
longdouble intpow(longdouble d, int exponent) {
  exponent = exponent.floor();
  longdouble result = new longdouble(1.0);
  var takeReciprocal = (exponent < 0);
  exponent = exponent.abs();
  var pow2 = d;
  while (exponent > 0) {
    //If the exponent is odd
    if (exponent & 1 == 1) {
      result = result * pow2;
    }
    exponent >>= 1;
    pow2 = pow2 * pow2;
  }
  return takeReciprocal ? result.reciprocal : result;
}

longdouble pow(longdouble d, num exponent) {
  throw 'NotImplemented';
}

longdouble sqrt(longdouble d) {
  throw 'NotImplemented';
}

longdouble sin(longdouble d) {
  throw 'NotImplemented';
}

longdouble cos(longdouble d) {
  throw 'NotImplemented';
}

longdouble tan(longdouble d) {
  throw 'NotImplemented';
}

longdouble sinh(longdouble d) {
  throw 'NotImplemented';
}

longdouble cosh(longdouble d) {
  throw 'NotImplemented';
}

longdouble tanh(longdouble d) {
  throw 'NotImplemented';
}