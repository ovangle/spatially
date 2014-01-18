library noding.exception;

import 'package:spatially/base/coordinate.dart';

class NodingException implements Exception {
  final String msg;
  NodingException(String this.msg);
  
  factory NodingException.collapseAt(Coordinate c0) {
    return new NodingException(
        "Found collapsed segment at $c0");
  }
  
  String toString() =>
    "NodingException: $msg";
}