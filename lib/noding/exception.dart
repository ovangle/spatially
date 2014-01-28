//This file is part of Spatially.
//
//    Spatially is free software: you can redistribute it and/or modify
//    it under the terms of the GNU Lesser General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    Spatially is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU Lesser General Public License for more details.
//
//    You should have received a copy of the GNU Lesser General Public License
//    along with Spatially.  If not, see <http://www.gnu.org/licenses/>.


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