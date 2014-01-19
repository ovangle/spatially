library spatially.base.tuple_tests;

import 'package:unittest/unittest.dart';
import 'package:spatially/base/tuple.dart';

main() {
  group("tuple: ", () {
    test("should be able to project the item", () {
      Tuple t1 = new Tuple(1, 2);
      expect(t1.project(1), 1);
      expect(t1.project(2), 2);
    });

    test("should be able to project the other item", () {
      Tuple t1 = new Tuple(1, 2);
      expect(t1.projectOther(1), 2);
      expect(t1.projectOther(2), 1);
    });

    test("zip should pair elements together", () {
      Iterable<int> iter1 = [1,2,3,4,5,6];
      Iterable<int> iter2 = ["hello", "world", "how", "are", "you", "today"];
      expect(zip(iter1, iter2),
          [ new Tuple(1, "hello"),
            new Tuple(2, "world"),
            new Tuple(3, "how"),
            new Tuple(4, "are"),
            new Tuple(5, "you"),
            new Tuple(6, "today")]);
    });

    test("zip should use the shortest iterable", () {
      Iterable<int> iter1 = [1,2,3,4,5,6];
      Iterable<int> iter2 = [11,12,13];

      expect(zip(iter1, iter2), [new Tuple(1,11), new Tuple(2, 12), new Tuple(3, 13)]);
      expect(zip(iter2, iter1), [new Tuple(11,1), new Tuple(12,2), new Tuple(13,3)]);
    });
  });
}