library algorithms;

/**
 * Implementations of various useful geometric algorithms.
 * 
 * This library is not intended to be imported directly, it contains
 * implementations of algorithms exposed via the [geometry.dart] API.
 */

import 'dart:math' hide Point;
import 'dart:collection';

import 'package:tuple/tuple.dart';
import 'utils.dart' as util;

import 'geometry.dart';

part 'src/algorithms/vicenty.dart';
part 'src/algorithms/bentley_ottmann.dart';