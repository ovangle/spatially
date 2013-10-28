part of algorithms;

// Semi major axis of ellipsoid (radius of earth at equator)
// in SI metres
const a = 6378137.0;

// Flatening of the ellipsoid
const f = 1/298.257223563;

// Length of semi-minor axis of ellipsoid (radius of earth at poles)
// in SI metres
const b = (1 - f) * a;

/**
 * An implementation of the Vicenty algorithm for determining the
 * distances between points on an ellipsoid
 * 
 * Taken from http://en.wikipedia.org/wiki/Vincenty's_formulae
 * 
 * [:inDegrees:] -- are the arguments provided in degrees or radians
 *                  (defaults to false).
 */

double vicentyDistance({double lat1, 
                        double lng1, 
                        double lat2, 
                        double lng2,
                        inDegrees: false}) {
  if (inDegrees) {
    lat1 = util.degreesToRadians(lat1);
    lat2 = util.degreesToRadians(lat2);
    lng1 = util.degreesToRadians(lng1);
    lng2 = util.degreesToRadians(lng2);
  }
  // Obtains the latitude of the auxillary sphere.
  double reduceLatitude(double lat) => atan((1 - f) * tan(lat));
  final rLat1 = reduceLatitude(lat1);
  final rLat2 = reduceLatitude(lat2);
  
  final dLng = lng2 - lng1;
  
  // azimuth at the equator
  var alpha;
  // ellipsoidal distance between the two points
  var s;
  // arc length between points on the auxliary sphere
  var sigma;
  
  var guess = dLng;
  var lastGuess = double.INFINITY;
  
  //Loop variables
  var sinSigma, cosSigma, sinAlpha, cosSqrAlpha, cos2Sigma_m;
  while ((guess - lastGuess).abs() > 1e-12) {
    sinSigma = _getSinSigma(rLat1, rLat2, guess);
    cosSigma = _getCosSigma(rLat1, rLat2, guess);
    
    sigma = atan2(sinSigma, cosSigma);
    
    sinAlpha    = _getSinAlpha(rLat1, rLat2, sinSigma, guess);
    cosSqrAlpha = 1 - sinAlpha * sinAlpha;
    cos2Sigma_m = _getCos2Sigma_m(rLat1, rLat2, cosSigma, cosSqrAlpha);
    
    lastGuess = guess;
    guess = _getGuess(dLng, sinAlpha, cosSqrAlpha, sigma, sinSigma, cosSigma, cos2Sigma_m);
    if (guess > PI) {
      throw new Exception("Vicenty formula failed to converge "
                          " for points <$lat1, $lng1>, <$lat2, $lng2>");
    }
  }
  final uSqr = cosSqrAlpha * (a * a - b * b) / (b * b);
  final deltaSigma = _getDeltaSigma(uSqr, sinSigma, cosSigma, cos2Sigma_m);
  
  return b * _getA(uSqr) * (sigma - deltaSigma);
}

// Expressions for inverse method
double _getA(double uSqr) {
  final a0 = 320 - 175 * uSqr;
  final a1 = -768 + uSqr * a0;
  final a2 = 4096 + uSqr * a1;
  return 1 + (uSqr / 16384) * a2;
}

double _getB(double uSqr) {
  final b0 = 74 - 47 * uSqr;
  final b1 = -128 + uSqr * b0;
  final b2 = 256  + uSqr * b1;
  return (uSqr / 1024) * b2;
}

double _getC(double cosSqrAlpha) {
  var x = 4 + f * (4 - 3 * cosSqrAlpha);
  return (f / 16) * cosSqrAlpha * (x);
}

double _getGuess(double dLng,
                 double sinAlpha, 
                 double cosSqrAlpha,
                 double sigma, 
                 double sinSigma, 
                 double cosSigma,
                 double cos2Sigma_m) {
  final C = _getC(cosSqrAlpha);
  final x0 = -1 + 2 * cos2Sigma_m * cos2Sigma_m;
  final x1 = cos2Sigma_m + C * cosSigma * x0;
  final x2 = sigma + C * sinSigma * x1;
  return dLng + (1 - C) * f * sinAlpha * x2;  
}

double _getDeltaSigma(double uSqr, double sinSigma, double cosSigma, double cos2Sigma_m) {
  final B = _getB(uSqr);
  final x0 = -3 + 4 * cos2Sigma_m * cos2Sigma_m;
  final x1 = -3 + 4 * sinSigma * sinSigma;
  final x  = (B / 6) * cos2Sigma_m * x0 * x1;
  
  final y0 = cosSigma * (-1 + 2 * cos2Sigma_m * cos2Sigma_m);
  final y = (B / 4) * (y0 - x);
  return B * sinSigma * (cos2Sigma_m + y);
}

double _getSinSigma(double rLat1, double rLat2, double guess) {
  final x = cos(rLat2) * sin(guess);
  final y = cos(rLat1) * sin(rLat2) - sin(rLat1) * cos(rLat2) * cos(guess);
  return sqrt(x * x + y * y);
}

double _getCosSigma(double rLat1, double rLat2, double guess) {
  return sin(rLat1) * sin(rLat2) 
       + cos(rLat1) * cos(rLat2) * cos(guess);
}

double _getSinAlpha(double rLat1, double rLat2, double sinSigma, double guess) {
  return cos(rLat1) * cos(rLat2) * sin(guess) / sinSigma;
}

double _getCos2Sigma_m(double rLat1, double rLat2, double cosSigma, double cosSqrAlpha) {
  //Test whether on equator
  if (cosSqrAlpha == 0.0) return 0.0;
  return cosSigma - 2 * sin(rLat1) * sin(rLat2) / cosSqrAlpha;  
}
