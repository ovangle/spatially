part of base.longdouble;

const _LongdoubleCodec _LD_CODEC = const _LongdoubleCodec();

class _LongdoubleCodec extends Codec<longdouble,String> {
  static const _LongdoubleEncoder LD_ENCODER = const _LongdoubleEncoder();
  static const _LongdoubleDecoder LD_DECODER = const _LongdoubleDecoder();

  const _LongdoubleCodec();
  
  Converter<longdouble,String> get encoder => LD_ENCODER;
  Converter<String,longdouble> get decoder => LD_DECODER;
  
}

class _LongdoubleEncoder extends Converter<longdouble,String> {
  
  const _LongdoubleEncoder();
  
  String convert(longdouble value) {
  }
}

class _LongdoubleDecoder extends Converter<String,longdouble> {
  static const int PLUS_SYMBOL = 0x2B /* + */;
  static const int MINUS_SYMBOL = 0x2D /* - */;
  static const int POINT_SYMBOL   = 0x2E /* . */;
  static const List<int> EXP_SYMBOLS   = const[0x45,0x65] /* e|E */;
  
  static const String INFINITY = "Infinity";
  static const String NAN = "NaN";
  
  /**
   * Returns the value of the digit if the rune represents
   * the code point of a decimal digit, else returns -1;
   */
  static digitValue(int rune) {
    if (rune >= 0x30 && rune < 0x3A) {
      return rune - 0x30;
    }
    return -1;
  }
  
  const _LongdoubleDecoder();
  
  longdouble convert(String input) {
    //Remove leading and trailing whitespace chars.
    input = input.trim();
    Iterator<int> runes = input.runes.iterator;
    
    var pos = 0;
    bool isPositive = true;
   
    if (!runes.moveNext()) {
      throw new FormatException(input);
    }
    if (runes.current == PLUS_SYMBOL) {
      if (!runes.moveNext()) throw 
      pos++;
    } else if (runes.current == MINUS_SYMBOL) {
      isPositive = false;
      pos++;
    }
    if (input.startsWith(INFINITY, pos)) {
      return (isPositive) ? longdouble.INFINITY : longdouble.NEGATIVE_INFINITY;
    } else if (input.startsWith(NAN, pos)) {
      return longdouble.NAN;
    }
    //record the position of the decimal separator so numbers can
    //be scaled later
    int pointPos = -1;
    List<int> digits = new List<int>();
    while (runes.moveNext()) {
      int rune = runes.current;
      pos++;
      if (rune == POINT_SYMBOL) {
        pointPos = pos - 1;
        continue;
      }
      var digit = digitValue(rune);
      if (digit >= 0) {
        digits.add(digit);
      } else {
        break;
      }
    }
    
    if (pos >= runes.length) {
      return construct(digits, pointPos, isPositive);
    } else if (EXP_SYMBOLS.contains(runes.elementAt(pos++))) {
      return construct(digits, pointPos, isPositive, parseExp(input, pos));
    } else {
      throw new FormatException(input);
    }
  }
  
  int parseExp(String input, int pos) {
    var runes = input.trim().runes;
    bool isExpPositive = true;
    if (runes.elementAt(pos) == PLUS_SYMBOL) {
      pos++;
    } else if (runes.elementAt(pos) == MINUS_SYMBOL) {
      isExpPositive = false;
      pos++;
    }
    List<int> expDigits = new List<int>();
    while(pos < runes.length) {
      var digit = digitValue(runes.elementAt(pos));
      if (digit >= 0) {
        expDigits.add(digit);
      } else {
        break;
      }
    }
    if (pos < runes.length || expDigits.isEmpty) {
      throw new FormatException(input);
    }
    var sign = isExpPositive ? 1 : -1;
    return sign * expDigits.reversed.fold(0, (exp, d) => 10 * exp + d);
  }

  
  longdouble construct(List<int> mantissaDigits, int pointPos, bool isPositive, [int exp=0]) {
    longdouble mantissa = new longdouble.zero();
    longdouble fracPower = new longdouble(1.0);
    for (var i = 0; i < mantissaDigits.length; i++) {
      mantissa = mantissa * 10 + mantissaDigits[i];
      if (pointPos != -1 && i >= pointPos) {
        fracPower = fracPower * 10;
      }
    }
    var sign = isPositive ? 1.0 : -1.0;
    mantissa = mantissa / fracPower;
    final exponent = math_ld.intpow(new longdouble(10.0), exp);
    return mantissa * exponent * sign;
  }
}