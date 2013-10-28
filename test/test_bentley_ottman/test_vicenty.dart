library test_vicenty;

import 'package:unittest/unittest.dart';
import 'package:layers/algorithms.dart';

void main() {
  test("Distance from <0,0> to <1,1>",
      () => expect(vicentyDistance(lat1: 0.0, lng1: 0.0, lat2: 1.0, lng2:1.0, inDegrees: true),
                  closeTo(156899.568, 0.0005)));
  test("Slow convergence test",
      () => expect(vicentyDistance(lat1:0.0, lng1: 0.0, lat2: 0.5, lng2: 179.5, inDegrees: true),
                   closeTo(19936288.579, 0.0005)));
  test("Flinders peak to Buninyong",
      () => expect(vicentyDistance(lat1: -37.95103, lng1: 144.42487,lat2: -37.65282,lng2: 143.92650, inDegrees: true),
                   closeTo(54971.954, 0.0005)));
}