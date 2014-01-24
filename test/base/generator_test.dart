library spatially.base.generator_test;

import 'package:unittest/unittest.dart';
import 'package:spatially/base/generator.dart';

range(start,stop,step) {
  var i;
  generator(bool isInit) {
    if (isInit) {
      i = start;
      return i;
    }
    i += step;
    if (i >= stop) {
      return null;
    }
    return i;
  }
  return generate(generator);
}

main() {
  group("generator", () {
    test("mock generator", () {
      expect(range(0,10,2), [0,2,4,6,8]);
      expect(range(0,10,3), [0,3,6,9]);
    });

    test("yield", () {
      expect(yield(4, () => yield(5, () => yield(6))), [4,5,6]);
    });

    test("should be able to return null from yield", () {
      expect(yield(4, () => yield(null, () => yield(6))), [4,null,6]);
    });

    test("yield empty", () {
      expect(yield(yieldBreak), []);
    });
  });

}