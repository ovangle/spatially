import 'dart:collection';

import 'package:range/range.dart';
import 'package:layers/utils.dart' as util;
import 'package:layers/geometry.dart';

void main() {
  final lseg1 = new LineSegment(new Point(x: 0.0, y: 0.0), new Point(x: 1.0, y: 1.0));
  final lseg2 = new LineSegment(new Point(x: 0.0, y: 0.0), new Point(x: 1.0, y: 1.0));
  final l = [lseg1];
  print(l.contains(lseg2));
}