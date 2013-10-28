part of geometry;

/**
 * The radius of the earth in SI metres.
 */

/**
 * A [LatLng] is the point on the surface of the earth defined by the ray
 * extending from the center of the earth, [:lng:] degrees to the east of the 
 * Greenwich meridian and [:lat:] degrees to the north of the equator.
 */
class LatLng extends Geometry {
  final double lng;
  final double lat;
  
  double get latRadians => utils.degreesToRadians(lat);
  double get lngRadians => utils.degreesToRadians(lng);
   
  const LatLng({double this.lng, double this.lat});
  LatLng.fromRadians({double lat, double lng})
      : this(lat: utils.radiansToDegrees(lat),
             lng: utils.radiansToDegrees(lng));
  
  LatLng.fromArray(List<double> arr) : this(lng: arr[0], lat: arr[1]);
  
  List<double> toArray() => [lng, lat];

  /**
   * Returns the distance between the two coordinates in coordinate space.
   * Does not represent real-world distances
   */
  double distanceTo(Geometry other) {
    if (other is LatLng) {
      var latLng = other as LatLng;
      var dLat = latLng.lat - lat;
      var dLng = latLng.lng - lng;
      return math.sqrt(dLat * dLat + dLng * dLng);
    } else {
      return other.distanceTo(this);
    }
  }
  
  /**
   * Returns the geodesic distance to another [Geometry] on the earth
   */
  double geodesicDistanceTo(Geometry other) {
    if (other is LatLng) {
      var latLng = other as LatLng;
      return alg.vicentyDistance(
                    lat1: latRadians, 
                    lng1: lngRadians, 
                    lat2: latLng.latRadians, 
                    lng2: latLng.lngRadians);
    }
    return other.distanceTo(this);
  }
  
  /**
   * A new latLng with the longitude inside the specified [world_bounds].
   */
  LatLng wrapDateLine(Bounds world_bounds) {
    var newLng = lng;
    while (newLng >= world_bounds.east) { newLng -= world_bounds.width; }
    while (newLng < world_bounds.west)  { newLng += world_bounds.width; }
    return new LatLng(lat:lat, lng: newLng);
  }
  
  //Implementation of Geometry
  
  Bounds get bounds => new Bounds.fromDiagonal(southWest: this, northEast: this);
  
  
  
  /**
   * Adding two latLngs returns the result of adding the latitudes and longitudes
   * componentwise.
   */
  LatLng translate({double delta_lat: 0.0, 
                    double delta_lng: 0.0}) {
    return new LatLng(
        lat: lat + delta_lat,
        lng: lng + delta_lng);
  }
  
  LatLng scale(num delta, LatLng origin) {
    return new LatLng(
        lat: (lat - origin.lat) * delta + origin.lat,
        lng: (lng - origin.lng) * delta + origin.lng);
  }
  
  LatLng get centroid => this;
  
  LatLng rotate(num delta, LatLng origin, {bool inRadians: true}) {
    if (!inRadians) delta = utils.degreesToRadians(delta);
    final r = distanceTo(origin);
    final t = math.atan2(lat - origin.lat, lng - origin.lng);
    return new LatLng(
        lat: origin.lat + r * math.sin(t + delta),
        lng: origin.lng + r * math.cos(t + delta));
  }
  
  //Relations
  
  /**
   * Is the [LatLng] equal to [:other:], within a given [:tolerance:]?
   */
  bool equalTo(Geometry geom, {double tolerance: 1e-15}) {
    if (geom is LatLng) {
      var p = geom as LatLng;
      return utils.compareDoubles(lat, p.lat, tolerance) == 0
          && utils.compareDoubles(lng, p.lng, tolerance) == 0;
    }
    return false;
  }
  
  bool intersects(Geometry geom, {double tolerance: 1e-15}) {
    if (geom is LatLng) {
      return equalTo(geom, tolerance: tolerance);
    }
    return geom.intersects(this, tolerance: tolerance);
  }
  
  bool encloses(Geometry geom, {double tolerance: 1e-15}) {
    if (geom is LatLng) {
      return equalTo(geom, tolerance: tolerance);
    }
    return false;
  }
  
  bool operator ==(Object o) {
    if (o is LatLng) {
      return (o as LatLng).lat == lat
          && (o as LatLng).lng == lng;
    }
    return false;
  }
  
  int get hashCode => 31^2 * lng.hashCode + 31 * lat.hashCode + 31;

  String toString() => "LatLng(lng: $lng, lat: $lat)";
}