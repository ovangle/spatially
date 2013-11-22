library test_longdouble;

import 'package:unittest/unittest.dart';
import 'package:spatially/base/longdouble.dart';

void main() {
  testLongdouble();
  testLongdoubleParse();
}

void testLongdouble() {
  group("operations", () {
    group("addition", () {
      
    });
    group("subtraction", () {
      
    });
    group("multiplication", () {
      test("100 * 12.34", () {
        expect((new longdouble(100.0) * new longdouble(12.34)).toDouble(), 1234.0);
      });
      
    });
    group("division", () {
      
    });
  });
}

void testLongdoubleParse() {
  group("parse", () {
    test("\'1234\'", () {
      expect(longdouble.parse("1234"), equals(new longdouble(1234.0)));
    });
    test("\'-1234\'", () {
      expect(longdouble.parse("-1234"), equals(new longdouble(-1234.0)));
    });
    test("\'12.34\'", () {
      expect(longdouble.parse("12.34").toDouble(), equals(12.34));
    });
    test("\'1.234e-14", () {
      expect(longdouble.parse("1.234e-14"), equals(new longdouble(1.234e-14)));
    });
    
  });
}