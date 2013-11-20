library math_dd;

import 'longdouble.dart';

//PI
//E

longdouble min(longdouble dd1, longdouble dd2) =>
    dd1 >= dd2 ? dd2 : dd1;

longdouble max(longdouble dd1, longdouble dd2) =>
    dd1 >= dd2 ? dd1 : dd2;