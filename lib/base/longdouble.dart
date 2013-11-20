library base.doubledouble;

import 'dart:math' as math;

/**
  * Implementation of 106 bit precision floating point 
  * numbers
  */

class longdouble implements Comparable<longdouble>{
  static const longdouble PI = 
      const longdouble(math.PI, 1.224646799353209e-16);
  
  static const longdouble E =
      const longdouble(math.E, 1.445646891729250158e-16);
  
  static const longdouble NAN =
      const longdouble(double.NAN, double.NAN);
  
  static const longdouble INFINITY = 
      const longdouble(double.INFINITY, 0.0);
  
  static const longdouble MAX_FINITE = 
      const longdouble(double.MAX_FINITE, 0.0);
  
  static const longdouble MIN_POSITIVE = 
      const longdouble(0.0, double.MIN_POSITIVE);
  
  static longdouble parse(String num) {
    throw 'NotImplemented';
  }
  
  final double lo;
  final double hi;
  
  const longdouble(double this.hi, double this.lo);
  
  const longdouble.fromDouble(double d) :
    this(d, 0.0);
  
  longdouble.fromDoubleDouble(longdouble dd) :
    this(dd.hi, dd.lo);
  
  bool get isNaN      => this.hi.isNaN || this.lo.isNaN;
  bool get isInfinite => this.hi.isInfinite;
  bool get isFinite   => !isInfinite;
  
  bool get isZero => hi == 0.0 && lo == 0.0;
  
  bool get isPositive =>
      hi > 0.0 || (hi == 0.0 && lo > 0.0);
  
  bool get isNegative => 
      hi < 0.0 || (hi == 0.0 && lo < 0.0);
  
  /**
   * Returns a [double] repreenting the closest
   */
  int floor() => hi.floor();
  double floorToDouble() => hi.floorToDouble();
  longdouble floorToDoubleDouble() => 
      new longdouble(hi.floorToDouble(), 0.0);
  
  int ceil() => hi.ceil();
  double ceilToDouble() => hi.ceilToDouble();
  longdouble ceilToDoubleDouble() => 
      new longdouble(hi.ceilToDouble(), 0.0);
  
  int round() => hi.round();
  double roundToDouble() => hi.roundToDouble();
  longdouble roundToDoubleDouble() => 
      new longdouble(hi.roundToDouble(), 0.0);
  longdouble operator +(longdouble dd) {
    final S = hi + dd.hi;
    final T = lo + dd.lo;
    
    var errorS = S - hi;
    var errorT = T - lo;
    
    var s = S - errorS;
    var t = T - errorT;
    
    s = (dd.hi - errorS) + (hi - s);
    t = (dd.lo - errorT) + (lo - t);
    
    errorT = s + T; 
    var H = S + e;
    var h = e + (S - H);
    e = t + h;
    
    var newLo = H + e;
    var newHi = e + (H - newLo);
    return new longdouble(newLo, newHi);
  }
  
  longdouble operator -() {
    throw 'NotImplemented';
  }
  
  longdouble operator -(longdouble dd) =>
      this + (-dd);
  
  longdouble operator *(longdouble dd) {
    throw 'NotImplemented';
  }
  
  longdouble operator /(longdouble dd) {
    throw 'NotImplemented';
  }
  
  int compareTo(longdouble dd) {
    var cmpHi = hi.compareTo(dd.hi);
    if (cmpHi != 0) return cmpHi;
    return lo.compareTo(dd.lo);
  }
  
  bool operator >(longdouble other) =>
      compareTo(other) > 0;
  bool operator >=(longdouble other) =>
      compareTo(other) >= 0;
  bool operator <(longdouble other) =>
      compareTo(other) < 0;
  bool operator <=(longdouble other) =>
      compareTo(other) <= 0;
  
  bool operator ==(Object o) => o is longdouble 
                             && o.hi == hi
                             && o.lo == lo;
}