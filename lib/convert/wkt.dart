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


library convert.wkt;

import 'dart:convert';
import 'dart:collection';

import 'package:quiver/iterables.dart';
import 'package:spatially/geom/base.dart';
import 'package:spatially/base/coordinate.dart';

/**
 * A [Codec] for converting [Geometry] objects to their
 * representations in the Well-Known Text format
 * as described in section 7 of
 * the OGC Simple Features Standard Part 1 - Common Architecture.
 *
 * Coordinates are encoded and parsed as either 2d or
 * 3d coordinates. The following case-insensitive tagged text types
 * are supported and correspond to the following geometries.
 *
 * -- point           -> [Point]
 * -- linestring      -> [Linestring]
 * -- polygon         -> [Polygon]
 * -- multipoint      -> [MultiPoint]
 * -- multilinestring -> [MultiLinestring]
 * -- multipolygon    -> [MultiPolygon]
 * -- geometrycollection -> [GeometryList]
 *
 * The other WKT tag types will cause a [WktParseError]
 * if encountered in the stream.
 *
 * The [Codec] also supports the non-standard tag
 * -- linearring      -> [Ring]
 */
class WktCodec extends Codec<Geometry, String> {
  final GeometryFactory factory;
  WktCodec(GeometryFactory this.factory);
  Converter<Geometry,String> get encoder  => new WktEncoder();
  Converter<String, Geometry> get decoder => new WktDecoder(factory);
}

class WktEncoder extends Converter<Geometry, String> {

  String convert(Geometry geom) => encodeGeometry(new StringBuffer(), geom);

  /**
   * A [Geometry] in WKT is encoded as
   */
  String encodeGeometry(StringBuffer sbuf, Geometry geom) {
    if (geom is GeometryList) {
      if (geom is MultiPolygon) {
        sbuf.write(_WktKeyword.MULTIPOLYGON_TAG);
        sbuf.write(" ");
        var multiPolyCoords = new List<List<Iterable<Coordinate>>>();
        for (var poly in geom) {
          var polyCoords = new List<Iterable<Coordinate>>();
          polyCoords.add(poly.exteriorRing.coordinates);
          poly.interiorRings.map((r) => r.coordinates).forEach(polyCoords.add);
          multiPolyCoords.add(polyCoords);
        }
        _encodeIterable(sbuf, multiPolyCoords);
        return sbuf.toString();
      } else if (geom is MultiLinestring) {
        sbuf.write(_WktKeyword.MULTILINESTRING_TAG);
      } else if (geom is MultiPoint) {
        sbuf.write(_WktKeyword.MULTIPOINT_TAG);
      } else {
        sbuf.write(_WktKeyword.COLLECTION_TAG);
        sbuf.write(" ");
        _encodeIterable(sbuf, geom);
        return sbuf.toString();
      }
      sbuf.write(" ");
      _encodeIterable(sbuf, geom.map((g) => g.coordinates));
      return sbuf.toString();
    } else if (geom is Point) {
      sbuf.write(_WktKeyword.POINT_TAG);
    } else if (geom is Ring) {
      sbuf.write(_WktKeyword.LINEARRING_TAG);
    } else if (geom is Linestring) {
      sbuf.write(_WktKeyword.LINESTRING_TAG);
    } else if (geom is Polygon) {
      sbuf.write(_WktKeyword.POLYGON_TAG);
      var polyrings = new List();
      polyrings.add(geom.exteriorRing);
      polyrings.addAll(geom.interiorRings);
      sbuf.write(" ");
      _encodeIterable(sbuf, polyrings.map((r) => r.coordinates));
      return sbuf.toString();
    } else {
      throw new UnsupportedError("Unsupported geometry type: ${geom.runtimeType}");
    }
    sbuf.write(" ");
    _encodeIterable(sbuf, geom.coordinates);
    return sbuf.toString();
  }

  void _encodeIterable(StringBuffer sbuf, Iterable seq) {
    if (seq.isEmpty) {
      sbuf.write(_WktKeyword.EMPTY);
      return;
    }
    sbuf.write("(");
    if (seq.first is Coordinate) {
      _encodeCoordinate(sbuf, seq.first);
      for (var coord in seq.skip(1)) {
        sbuf.write(", ");
        _encodeCoordinate(sbuf, coord);
      }
    } else if (seq.first is Geometry) {
      encodeGeometry(sbuf, seq.first);
      for (var geom in seq.skip(1)) {
        sbuf.write(", ");
        encodeGeometry(sbuf, geom);
      }
    } else if (seq.first is Iterable) {
      _encodeIterable(sbuf, seq.first);
      for (var subSeq in seq.skip(1)) {
        sbuf.write(", ");
        _encodeIterable(sbuf, subSeq);
      }
    } else {
      //We should only see lists of coordinates or
      //nested lists of coordinatess
      assert(false);
    }
    sbuf.write(")");
  }

  /**
   * A [Coordinate] in WKT is expresssed
   * as a string
   *      COORD := DOUBLE DOUBLE [DOUBLE]
   * where NUM is a dart-style double value
   */
  String _encodeCoordinate(StringBuffer sbuf, Coordinate c) {
    sbuf.write("${c.x} ${c.y}");
    if (!c.is2d) {
      sbuf.write(" ${c.z}");
    }
    return sbuf.toString();
  }
}

class WktDecoder extends Converter<String,Geometry> {
  GeometryFactory factory;

  WktDecoder(GeometryFactory this.factory);

  Geometry convert(String input) => _parseGeometry(new _TokenIterator(input));

  Geometry _parseGeometry(_TokenIterator tokens) {
    if (tokens.moveNext()) {
      _Token currentToken = tokens.current;
      if (currentToken is _WktKeyword) {
        switch(currentToken.value) {
          case _WktKeyword.POINT_TAG:
            return _parsePoint(tokens);
          case _WktKeyword.LINESTRING_TAG:
            return _parseLinestring(tokens);
          case _WktKeyword.LINEARRING_TAG:
            return _parseRing(tokens);
          case _WktKeyword.POLYGON_TAG:
            return _parsePolygon(tokens);
          case _WktKeyword.MULTIPOINT_TAG:
            return _parseMultiPoint(tokens);
          case _WktKeyword.MULTILINESTRING_TAG:
            return _parseMultiLinestring(tokens);
          case _WktKeyword.MULTIPOLYGON_TAG:
            return _parseMultiPolygon(tokens);
          case _WktKeyword.COLLECTION_TAG:
            return _parseGeometryCollection(tokens);
          default:
            throw new WktParseError(
                "Unrecognised geometry tag (${currentToken.value}) "
                "at position ${currentToken.position}");
        }
      }
    } else {
      throw new WktParseError("Empty input");
    }
  }

  Point _parsePoint(_TokenIterator tokens) {
    List<Coordinate> pointCoords = _parseCoordinateSequence(tokens);
    if (pointCoords.isEmpty)
      return factory.createEmptyPoint();
    if (pointCoords.length > 1) {
      throw new WktParseError("Too many coordinates for valid Point geometry");
    }
    return factory.createPoint(pointCoords.single);
  }

  Linestring _parseLinestring(_TokenIterator tokens) =>
      factory.createLinestring(_parseCoordinateSequence(tokens));
  Ring _parseRing(_TokenIterator tokens) =>
      factory.createRing(_parseCoordinateSequence(tokens));

  Polygon _parsePolygon(_TokenIterator tokens) {
    var polyRings = _parseCoordinateSequenceList(tokens);
    if (polyRings.isEmpty)
      return factory.createEmptyPolygon();
    return factory.createPolygon(
        factory.createRing(polyRings.first),
        polyRings.skip(1).map(factory.createRing));
  }

  MultiPoint _parseMultiPoint(_TokenIterator tokens) {
    var multipointCoords = _parseCoordinateSequenceList(tokens);
    if (multipointCoords.isEmpty)
      return factory.createEmptyMultiPoint();
    var points = new List<Point>();
    for (var i in range(multipointCoords.length)) {
      if (multipointCoords[i].length != 1) {
        throw new WktParseError("Point $i in multipoint has an invalid number of coordinates");
      }
      points.add(factory.createPoint(multipointCoords[i].single));
    }
    return factory.createMultiPoint(points);
  }

  MultiLinestring _parseMultiLinestring(_TokenIterator tokens) =>
      factory.createMultiLinestring(
          _parseCoordinateSequenceList(tokens)
          .map(factory.createLinestring));

  MultiPolygon _parseMultiPolygon(_TokenIterator tokens) {
    var polys = new List<Polygon>();
    if (!tokens.moveNext()
         || (tokens.current.value != _WktDelimeter.L_PARENS
             && tokens.current.value != _WktKeyword.EMPTY)) {
      throw new WktParseError("Expected the start of a list of ring coordinates "
                              "at position ${tokens.current.endPos}");
    }
    if (tokens.current.value == _WktKeyword.EMPTY)
      return factory.createEmptyMultiPolygon();
    while (true) {
      var polyCoords = _parseCoordinateSequenceList(tokens);
      if (polyCoords.isEmpty) {
        polys.add(factory.createEmptyPolygon());
      } else {
        polys.add(factory.createPolygon(factory.createRing(polyCoords.first),
                                        polyCoords.skip(1).map(factory.createRing)));
      }
      if (!tokens.moveNext()
          || (tokens.current.value != _WktDelimeter.COMMA
              && tokens.current.value != _WktDelimeter.R_PARENS)) {
        throw new WktParseError("Expected the end of a list of ring coordinates "
                                "at position ${tokens.current.endPos}");
      }
      if (tokens.current.value == _WktDelimeter.R_PARENS) {
        return factory.createMultiPolygon(polys);
      }
    }
  }

  GeometryList _parseGeometryCollection(_TokenIterator tokens) {
    if (!tokens.moveNext()
         || (tokens.current.value != _WktDelimeter.L_PARENS
            && tokens.current.value != _WktKeyword.EMPTY)) {
      throw new WktParseError("Expected the start of a GeometryList "
                              "at position ${tokens.current.position}");
    }
    GeometryList geomList = factory.createEmptyGeometryList();
    if (tokens.current.value == _WktKeyword.EMPTY)
      return geomList;
    while (true) {
      geomList.add(_parseGeometry(tokens));
      if (!tokens.moveNext()
          || (tokens.current.value != _WktDelimeter.R_PARENS
              && tokens.current.value != _WktDelimeter.COMMA)) {
        throw new WktParseError("Expected the end of a GeometryList or another Geometry "
                                "at position ${tokens.current.position}");
      }
      if (tokens.current.value == _WktDelimeter.R_PARENS) {
        return geomList;
      }
    }
  }

  List<List<Coordinate>> _parseCoordinateSequenceList(_TokenIterator tokens) {
    if (!tokens.moveNext()
        || (tokens.current.value != _WktDelimeter.L_PARENS
           && tokens.current.value != _WktKeyword.EMPTY)) {
      throw new WktParseError("Expected the start of a coordinate sequence list "
                              "at position ${tokens.current.position}");
    }
    var coordSeqs = new List<List<Coordinate>>();
    if (tokens.current.value == _WktKeyword.EMPTY) {
      return coordSeqs;
    }
    while(true) {
      coordSeqs.add(_parseCoordinateSequence(tokens));
      if (!tokens.moveNext()
          || (tokens.current.value != _WktDelimeter.R_PARENS
              && tokens.current.value != _WktDelimeter.COMMA)) {
        throw new WktParseError("Expected the end of a coordinate sequence list "
                                "or another coordinate sequence "
                                "at position ${tokens.current.position}");
      }
      if (tokens.current.value == _WktDelimeter.R_PARENS) {
        return coordSeqs;
      }
    }
  }

  List<Coordinate> _parseCoordinateSequence(_TokenIterator tokens) {
    if (!tokens.moveNext()
        || (tokens.current.value != _WktDelimeter.L_PARENS
            && tokens.current.value != _WktKeyword.EMPTY)) {
      throw new WktParseError("Expected start of coordinate sequence"
                              "at ${tokens.current.endPos}");
    }
    var coords = new List<Coordinate>();
    if (tokens.current.value == _WktKeyword.EMPTY)
      return coords;
    while (true) {
      coords.add(_parseCoordinate(tokens));
      if (!tokens.moveNext()
          || (tokens.current.value != _WktDelimeter.R_PARENS
              && tokens.current.value != _WktDelimeter.COMMA)) {
        throw new WktParseError("Expected next coordinate or end of list "
                                "at ${tokens.current.endPos})");
      }
      if (tokens.current.value == _WktDelimeter.R_PARENS) {
        return coords;
      }
    }
  }

  Coordinate _parseCoordinate(_TokenIterator tokens) {
    double x = parseOrdinate(tokens);
    double y = parseOrdinate(tokens);
    _Token maybeZ = tokens.peekNext();
    double z = double.NAN;
    if (maybeZ is _WktNumber) {
      z = parseOrdinate(tokens);
    }
    return new Coordinate(x, y, z);
  }
  double parseOrdinate(_TokenIterator tokens) {
    if (!tokens.moveNext()
        || tokens.current is! _WktNumber) {
      throw new WktParseError("Expected an ordinate at ${tokens.current.endPos}");
    }
    return tokens.current.value;
  }
}

class _TokenIterator extends Iterator<_Token> {
  static const List<int> WHITESPACE =
      const [0x08, 0x09, 0x0a, 0x0d, 0x20];

  final String input;
  _Token currentToken;
  _TokenIterator(String this.input);

  _Token get current {
    return currentToken;
  }

  bool moveNext() {
    var strPos = currentToken != null ? currentToken.endPos : 0;
    while (strPos < input.length
        && WHITESPACE.contains(input.codeUnitAt(strPos++)));
    strPos--;
    if (strPos >= input.length) {
      return false;
    }
    currentToken = _WktKeyword.next(input, strPos);
    if (currentToken != null) return true;
    currentToken = _WktDelimeter.next(input, strPos);
    if (currentToken != null) return true;
    currentToken = _WktNumber.next(input, strPos);
    if (currentToken != null) return true;
    throw new WktParseError("Unrecognised token in string at position $strPos");
  }

  _Token peekNext() {
    var strPos = currentToken != null ? currentToken.endPos : 0;
    while (strPos < input.length
          && WHITESPACE.contains(input.codeUnitAt(strPos++)));
    if (strPos == input.length) {
      return null;
    }
    _Token nextToken;
    nextToken = _WktKeyword.next(input, strPos);
    if (nextToken != null) return nextToken;
    nextToken = _WktDelimeter.next(input, strPos);
    if (nextToken != null) return nextToken;
    nextToken = _WktNumber.next(input, strPos);
    if (nextToken != null) return nextToken;
    return null;
  }

}

class _Token {
  final int position;
  //The index into the string at the end of the token
  final int endPos;

  final dynamic value;
  _Token(this.value, int this.position, int this.endPos);
}



class _WktKeyword extends _Token {
  static const String POINT_TAG = "POINT";
  static const String LINESTRING_TAG = "LINESTRING";
  static const String LINEARRING_TAG = "LINEARRING";
  static const String POLYGON_TAG    = "POLYGON";
  static const String MULTIPOINT_TAG = "MULTIPOINT";
  static const String MULTILINESTRING_TAG = "MULTILINESTRING";
  static const String MULTIPOLYGON_TAG = "MULTIPOLYGON";
  static const String COLLECTION_TAG   = "GEOMETRYCOLLECTION";

  static const String EMPTY            = "EMPTY";

  static const List<String> _kwds =
      const [ POINT_TAG, LINESTRING_TAG, LINEARRING_TAG, POLYGON_TAG,
              MULTIPOINT_TAG, MULTILINESTRING_TAG, MULTIPOLYGON_TAG, COLLECTION_TAG,
              EMPTY
            ];

  static final List<RegExp> _kwdRegexes =
      _kwds.map((kw) => new RegExp(kw, caseSensitive: false)).toList();

  _WktKeyword(value, int startPos, int endPos): super(value, startPos, endPos);

  static _WktKeyword next(String input, int strPos) {
    for (var i in range(_kwds.length)) {
      var kwdRegex = _kwdRegexes[i];
      if (input.startsWith(kwdRegex, strPos)) {
        var kwd = _kwds[i];
        return new _WktKeyword(kwd, strPos, strPos + kwd.length);
      }
    }
    return null;
  }
}

class _WktNumber extends _Token {
  _WktNumber(value, int startPos, int endPos) : super(value, startPos, endPos);

  /**
   * A number in wkt is defined as follows:
   *      NUMBER           := MAYBE_SIGN (NaN | (INT_PART MAYBE_FLOAT_PART MAYBE_EXP_PART))
   *      MAYBE_SIGN       := ('+' | '-') | ''
   *      INT_PART         := [0-9]*
   *      MAYBE_FLOAT_PART := FLOAT_PART | ''
   *      FLOAT_PART       := '.' [0-9]+
   *      MAYBE_EXP_PART   := EXP_PART | ''
   *      EXP_PART         := ('e' | 'E') MAYBE_SIGN [0-9]+
   */
  static final matchNumber =
      new RegExp( "[+-]?"
                  "([0-9]*\\.?[0-9]+([eE][+-]?[0-9]+)?)"
                  "|NaN");

  static _WktNumber next(String input, int strPos) {
    var match = matchNumber.matchAsPrefix(input, strPos);
    if (match != null) {
      return new _WktNumber(double.parse(match.group(0)), match.start, match.end);
    }
    return null;
  }
}

class _WktDelimeter extends _Token {
  static const L_PARENS = 0x28;
  static const R_PARENS = 0x29;
  static const COMMA    = 0x2C;
  static const List<int> _DELIMETERS = const [L_PARENS, R_PARENS, COMMA];

  _WktDelimeter(delim, int startPos, int endPos) : super(delim, startPos, endPos);

  static _WktDelimeter next(String input, int strPos) {
    for (var delim in _DELIMETERS) {
      if (input.codeUnitAt(strPos) == delim) {
        return new _WktDelimeter(delim, strPos, strPos + 1);
      }
    }
    return null;
  }
}

class WktParseError extends Error {
  String msg;
  WktParseError(String this.msg) : super();
  toString() => msg;
}
