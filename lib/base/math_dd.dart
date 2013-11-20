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