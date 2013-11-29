library algorithm.metric;

import 'package:spatially/geom/base.dart';

part 'src/metric/euclidean.dart';
part 'src/metric/hausdorff.dart';

/**
 * A metric is a method which measures some kind of distance between two
 * objects.
 */
typedef double Metric<T,U>(T t, U u);