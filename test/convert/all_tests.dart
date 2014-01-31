library spatially.convert.all_tests;

import 'package:unittest/unittest.dart';
import 'geojson_test.dart' as geojson;
import 'wkt_tests.dart' as wkt;

main() {
  group("convert: ", () {
    geojson.main();
    wkt.main();
  });
}