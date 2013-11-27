import 'dart:math';

void main() {
  print(0.0.compareTo(double.NAN));
  print(double.NAN.compareTo(double.NAN));
  
  print(double.NAN == double.NAN);
  print(double.NAN.compareTo(double.INFINITY));
}
  /*
  print(log(pow(2, 53)) / log(10));
  print(pow(2, 53));
  print(pow(10, 16));
  
  var xs = [1,2,3,4,5];
  print(xs.skip(17).toList());
  print(xs.take(17).toList());
  
  var ax = new longdouble(56.5286666667);
  var ay = new longdouble(25.2101666667);
  
  var bx = new longdouble(56.529);
  var by = new longdouble(25.2105);
  
  var cx = new longdouble(56.528833333300);
  var cy = new longdouble(25.2103333333);
  
  var s1 = ax * (by - cy);
  var s2 = bx * (cy - ay);
  var s3 = cx * (ay - by);
  
  print("s1: $s1");
  print("s2: $s2");
  print("s3: $s3");
  
  print("s1 + s2: ${s1 + s2}");
  print("s1 + s3: ${s1 + s3}");
  print("s2 + s3: ${s1 + s3}");
  
  print("s1 + s2 + s3: ${s1 + s2 + s3}");
  print("s1 + s2 + s3: ${ ax * (by - cy) + bx * (cy - ay) + cx * (ay - by)}");
  
  var area = s1 + s2 + s3;
  
  var area3 = area * 3.0;
  print("area3: $area3");
  print("area / area3: ${area / area3}");
  
  var centroidSumx = area * ((ax + bx + cx) / 3);
  var centroidSumy = area * ((ay + by + cy)  / 3);
  print("centroid sum x: ${centroidSumx}");
  print("sentroid sum y: ${centroidSumy}");
  
  var centroidx = centroidSumx / area;
  var centroidy = centroidSumy / area;
  print("centroid x: ${centroidx}");
  print("centroid y: ${centroidy}");
  
  var centroid = 
      new Coordinate((area * (ax + bx + cx) / (area * 3.0)).toDouble(),
                     (area * (ay + by + cy)  / (area * 3.0)).toDouble());
 print(centroid);
 
}
  */