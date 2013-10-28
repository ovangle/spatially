library test_latlng;

import 'dart:math' as math;
import 'package:unittest/unittest.dart';

import 'package:layers/geometry.dart';

void main() {
  testProperties();
  testDistance();
  testGeometryImpl();
  testScale();
  testRotate();
}

void testProperties() {
  var latLng = new LatLng(lng: 90.0, lat: 45.0);
  test("test_latlng: lngRadians is PI / 2",
      () => expect(latLng.lngRadians, equals(math.PI / 2)));
  test("test_latlng: latRadians is PI / 4",
      () => expect(latLng.latRadians, equals(math.PI / 4)));
}

void testDistance() {
  var sydLatLng = new LatLng(lng: 151.2167, lat: -33.8833);
  var melLatLng = new LatLng(lng: 144.9667, lat: -37.8167);
  test("test_latlng: Coordinate distance from sydney to melbourne is approx 7.3847 km",
      () => expect(sydLatLng.distanceTo(melLatLng),
                  closeTo(7.38472312, 0.000005)));
  test("test_latlng: Real distance from sydney to melbourne is approx 786388.121 km",
      () => expect(sydLatLng.geodesicDistanceTo(melLatLng),
                   closeTo(713306.320, 0.0005)));
}

void testScale() {
  var latLng = new LatLng(lat: 0.0, lng: 1.0);
  test("test_latlng: Scale $latLng by 2x about origin",
      () => expect(latLng.scale(2, new LatLng(lat: 0.0, lng: 0.0)),
                   equals(new LatLng(lat: 0.0, lng: 2.0))));
  
  test("test_latlng: Scale $latLng by 2x about <2.0, 2.0>",
      () => expect(latLng.scale(2, new LatLng(lat: 2.0, lng: 2.0)),
                   equals(new LatLng(lat: -2.0, lng: 0.0))));
            
}

void testRotate() {
  var latLng = new LatLng(lat: 1.0, lng: 0.0);
  var rotated = latLng.rotate(math.PI / 2, new LatLng(lat: 0.0, lng: 0.0));
  print(rotated);
  test("test_latlng: Rotate $latLng through PI/2 about origin",
      () => expect(rotated.equalTo(new LatLng(lat: 0.0, lng: -1.0), tolerance: 1e-10),
                   isTrue));
  
  var rotated2 = latLng.rotate(math.PI/4, new LatLng(lat: 0.0, lng: 0.0));
  var expected = new LatLng(lat: 1/math.sqrt(2), lng: -1/math.sqrt(2));
  test("test_latlng: Rotate $latLng through PI/4 about origin",
      () => expect(rotated2.equalTo(expected, tolerance: 1e-12),
                   isTrue));
  
  var rotated3 = latLng.rotate(math.PI/2, new LatLng(lat: 1.0, lng: 1.0));
  var expected2 = new LatLng(lat: 0.0, lng: 1.0);
  test("test_latlng: Rotate $latLng through PI/2 about <1.0, 1.0>",
      () => expect(rotated3.equalTo(expected2, tolerance: 1e-12),
                   isTrue));
}

void testGeometryImpl() {
  var latLng = new LatLng(lat: 0.0, lng: 0.0);
  var latLngBounds = new Bounds(south: 0.0, north: 0.0, west: 0.0, east: 0.0);
  test("test_latlng: bounds of $latLng is $latLngBounds",
      () => expect(latLng.bounds, equals(latLngBounds)));
}