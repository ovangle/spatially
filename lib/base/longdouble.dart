library base.longdouble;

import 'dart:math' as math;
import 'dart:convert';

import 'math_dd.dart' as math_ld;

part 'src/longdouble/convert.dart';

/**
  * Implementation of 106 bit precision floating point 
  * numbers.
  * 
  * Used mainly for maintaining robustness of double values
  * when used in coordinates
  * 
  * The implmentation in this module is taken from 
  * http://mrob.com/pub/math/f161.html, 
  * rather than from JTS.
  */

//TODO: Is there any way to avoid importing this module
//      when using a precision model other than FLOATING?
//      
//      I'm already starting to get worried about the 
//      eventual size of these libraries when exported to
//      js.

class longdouble implements Comparable<longdouble>{
  
  static const longdouble NAN =
      const longdouble(double.NAN, double.NAN);
  
  static const longdouble INFINITY = 
      const longdouble(double.INFINITY, double.INFINITY);
  
  static const longdouble NEGATIVE_INFINITY = 
      const longdouble(double.NEGATIVE_INFINITY, double.NEGATIVE_INFINITY);
  
  static const longdouble MAX_FINITE = 
      const longdouble(double.MAX_FINITE, double.MAX_FINITE);
  
  static const longdouble MIN_POSITIVE = 
      const longdouble(0.0, double.MIN_POSITIVE);
  
  /**
   * Parse [input] as a longdouble literal.
   * 
   * A longdouble literal will match the same pattern as a double literal,
   * with an optional sign, followed by a mantissal and exponent.
   * 
   * Leading and trailing whitespace is ignored.
   */
  
  static longdouble parse(String input, [longdouble onError(String input)]) {
    try {
      return _LD_CODEC.decode(input);
    } on FormatException catch (e) {
      if (onError != null) {
        return onError(input);
      }
      throw e;
    }
  }
  
  final double hi;
  final double lo;
  
  /**
   * Initialize a [longdouble] with the given [:hi:]
   * and [:lo:] double values.
   */
  const longdouble(double this.hi, [double this.lo = 0.0]);
  
  const longdouble.zero() : this(0.0, 0.0);
  
  /**
   * Return the value of `1.0 / this`. 
   * Since it's impossible to implement operators on double taking a left value of a [longdouble],
   * the only way to divide by a [longdouble] is to multiply by the reciprocal
   */
  longdouble get reciprocal => _longdouble_division(new longdouble(1.0), this);
  
  /**
   * Retrieve the result as a double value
   */
  double toDouble() => hi + lo;
  
  /**
   * scale the [longdouble] by the given [double] value
   */
  longdouble _scale(double value) => new longdouble(hi * value, lo * value);

  int compareToNum(num a) {
    var cmpHi = hi.compareTo(a);
    if (cmpHi != 0) return cmpHi;
    return lo.compareTo(0.0);
  }
  
  int compareTo(longdouble ld) {
    var cmpHi = hi.compareTo(ld.hi);
    if (cmpHi != 0) return cmpHi;
    return lo.compareTo(ld.lo);
  }
  
  longdouble abs() {
    if (hi < 0.0) {
      return new longdouble(-hi, -lo);
    } else if (hi > 0.0) {
      return this;
    } else if (lo < 0.0) {
      return new longdouble(-hi, -lo);
    } else {
      return this;
    }
  }
  
  int floor() => toDouble().floor();
  double floorToDouble() => toDouble().floorToDouble();
  
  int ceil() => toDouble().ceil();
  double ceilToDouble() => toDouble().ceilToDouble();
  
  longdouble operator -() => new longdouble(-hi, -lo);
  
  longdouble operator *(dynamic v) {
    if (v is num) {
      var t0 = _multDoubles(hi, v.toDouble());
      var d  = _multDoubles(lo, v.toDouble());
      
      var t1 = _addDoubles(t0.lo, d.hi);
      var t2 = d.lo + t1.lo;
      
      return _normalizeThree(t0.hi, t1.hi, t2);
    } else if (v is longdouble) {
      var multHiHi = _multDoubles(hi, v.hi);
      var multHiLo = _multDoubles(hi, v.lo);
      var multLoHi = _multDoubles(lo, v.hi);
      double multLoLo = lo * v.lo;
      
      var t1 = _addDoubles(multHiHi.lo, multHiLo.hi, multLoHi.hi);
      var t2 = multHiLo.lo + multLoHi.lo + multLoLo + t1.lo;
      
      return _normalizeThree(multHiHi.hi, t1.hi, t2);
    } else {
      throw new ArgumentError("right multiplicand of '*' must be a num or longdouble");
    }
  }
  
  longdouble operator +(dynamic v) {
    if (v is num) {
      
      var t0 = _addDoubles(hi, v.toDouble());
      var t1 = _addDoubles(lo, t0.lo);
      
      return _normalizeThree(t0.hi, t1.hi, t1.lo);
    } else if (v is longdouble) {
      
      var t0 = _addDoubles(hi, v.hi);
      var d  = _addDoubles(lo, v.lo);
      var t1 = _addDoubles(t0.lo, d.hi);
      double t2 = d.lo + t1.lo;
      
      return _normalizeThree(t0.hi, t1.hi, t2);
    } else {
      throw new ArgumentError("right operand of '+' must be num or longdouble");
    }
  }
  
  longdouble operator -(dynamic v) {
    if (v is num) {
      final t0 = _subtractDoubles(hi, v.toDouble());
      final t1 = _subtractDoubles(lo, t0.lo);
      return _normalizeThree(t0.hi, t1.hi, t1.lo);
    } else if (v is longdouble) {
      final t0 = _subtractDoubles(hi, v.hi);
      final d  = _subtractDoubles(lo, v.lo);
    
      final t1 = _addDoubles(t0.lo, d.hi);
      double t2 = d.lo + t1.lo;
      
      return _normalizeThree(t0.hi, t1.hi, t2);
    } else {
      throw new ArgumentError("right operand of '-' must be num or longdouble");
    }
  }
  
  longdouble operator /(dynamic v) {
    if (v is num) {
      return _longdouble_division(this, new longdouble(v.toDouble()));
    } else if (v is longdouble) {
      return _longdouble_division(this, v);
    } else {
      throw new ArgumentError("right operand of '/' must be num or longdouble");
    }
  }
  
  bool operator ==(Object o) {
    if (o is num) {
      return hi == o && lo == 0.0;
    } else if (o is longdouble) {
      return compareTo(o) == 0;
    }
    return false;
  }
  
  bool operator >(longdouble v) => compareTo(v) > 0;
  bool operator >=(longdouble v) => compareTo(v) >= 0;
  bool operator <(longdouble v) => compareTo(v) < 0;
  bool operator <=(longdouble v) => compareTo(v) <= 0;
  
  int get hashCode => 17 * hi.hashCode + lo.hashCode;
  
  String toString() => "longdouble($hi|$lo)";
}

/**
 * normalize two [double] values. 
 * [:a:] is assumed to be greater than [:b:]
 */
longdouble _normalizeTwo(double a, double b) {
  final sum = a + b;
  final err = b - (sum - a);
  return new longdouble(sum, err);
}

/**
 * normalize three double values, returning their sum
 * as a [longdouble]
 * [:a:] is assumed to be greater than [:b:]
 * and [:b:] is assumed to be greater than [:c:]
 */
longdouble _normalizeThree(double a, double b, double c) {
  var s0 = _normalizeTwo(b, c);
  var s1 = _normalizeTwo(a, s0.hi);
  double newLo;
  if (s1.lo != 0.0) {
    newLo = s1.lo + s0.lo;
  } else {
    s0 = _normalizeTwo(s1.hi, s0.lo);
    newLo = s0.lo;
  }
  return new longdouble(s1.hi, newLo);
}

//Cached constant used in split, to prevent recalculation
final _splitConst = math.pow(2, 27) + 1;

/**
 * Split the [double] value [:a:] into a new [longdouble] where 
 * the value returned has a [:hi:] value has the top `27` bits of precision
 * and the [:lo:] value has the bottom `27` bits of precision.
 */
longdouble _split(double a) {
  final y = _splitConst * a;
  final newHi = y - (y - a);
  return new longdouble(newHi, a - newHi);
}

/**
 * Multiply two doubles, returning the result as a normalized [longdouble]
 */
longdouble _multDoubles(double a, double b) {
  final newHi = a * b;
  //split both the doubles
  longdouble sa = _split(a);
  longdouble sb = _split(b);
  final newLo = 
      ((sa.hi * sb.hi - newHi) 
          + sa.hi * sb.lo + sb.hi * sa.lo) 
              + sa.lo * sb.lo;
  return new longdouble(newHi, newLo);
}

/**
 * Add two [double] values, returning the addition as a normalized [longdouble].
 */
longdouble _addDoubles(double a, double b, [double c = null]) {
  if (c == null) {
    //add_112
    final sum = a + b;
    final amtAdded = sum - a;
    final err = (a - (sum - amtAdded)) + (b - amtAdded);
    return new longdouble(sum, err);
  }
  //add_1113
  final sumTwo = _addDoubles(a, b);
  final sumThird = _addDoubles(sumTwo.hi, c);
  return new longdouble(sumThird.hi, sumTwo.lo + sumThird.lo);
}

/**
 * Subtract two [double] values, returning the difference as a normalized [longdouble]
 * //sub_112
 */
longdouble _subtractDoubles(double a, double b) {
  final diff = a - b;
  final amtSubtracted = diff - a;
  final err = (a - (diff - amtSubtracted)) - (b + amtSubtracted);
  return new longdouble(diff, err);
}

/**
 * The division algorithm begins with an approximation using the 
 * double division operation, then computes the error created and subtracts it out.
 */
longdouble _longdouble_division(longdouble a, longdouble b) {
  final initApprox = a.hi / b.hi;
  
  var result = b * initApprox;
  final s = _subtractDoubles(a.hi, result.hi);
  var slo = s.lo;
  slo -= result.lo;
  slo += a.lo;
  var newApprox = (s.hi + slo) / b.hi;
  
  return _normalizeTwo(initApprox, newApprox);
}