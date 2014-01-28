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


part of spatially.operation.overlay;

abstract class _OverlayBuilder {
  static int _getDim(Geometry g) {
    if (g is Point || g is MultiPoint) {
      return 1;
    } else if (g is Linestring || g is MultiLinestring) {
      return 2;
    } else if (g is Polygon || g is MultiPolygon) {
      return 3;
    } else if (g is GeometryList) {
      return g.fold(1, (g1,g2) => math.max(_getDim(g1), _getDim(g2)));
    }
    throw new GeometryError("Not a recognised geometry type");
  }

  final GeometryGraph graph;
  final GeometryFactory geomFactory;
  final int overlayType;

  _OverlayBuilder._(GeometryGraph graph,
                   int this.overlayType) :
    this.graph = graph,
    geomFactory = graph.geometries.$1.factory;

  factory _OverlayBuilder(GeometryGraph graph,
                         int overlayType) {
    var dims = graph.geometries.map(_getDim);
    var dim;
    switch(overlayType) {
      case OVERLAY_INTERSECTION:
      case OVERLAY_DIFFERENCE:
        //Take the minimum dimension
        dim = math.min(dims.$1, dims.$2);
        break;
      case OVERLAY_UNION:
      case OVERLAY_SYMMETRIC_DIFFERENCE:
        dim = math.max(dims.$1, dims.$2);
        break;
      default:
        throw new ArgumentError("Invalid overlay type");
    }

    switch(dim) {
      case 1:
        return new _PointBuilder(graph, overlayType);
      case 2:
        return new _LinestringBuilder(graph, overlayType);
      case 3:
        return new _PolygonBuilder(graph, overlayType);
    }
  }


  bool _inOverlay(Tuple<int,int> onLocations) {
    switch(overlayType) {
      case OVERLAY_INTERSECTION:
        return _inIntersection(onLocations);
      case OVERLAY_UNION:
        return _inUnion(onLocations);
      case OVERLAY_DIFFERENCE:
        return _inDifference(onLocations);
      case OVERLAY_SYMMETRIC_DIFFERENCE:
        return _inSymmetricDifference(onLocations);
      default:
        throw new ArgumentError("Invalid overlay type ($overlayType)");
    }
  }
  Geometry build();
}

class _PolygonBuilder extends _OverlayBuilder {
  _PolygonBuilder(graph, overlayType) : super._(graph, overlayType);
}

/**
 * Builds an empty geometry with dimension at least
 * the dimension of either of the geometries used to
 * create the graph
 */
class EmptyGeometryBuilder extends _OverlayBuilder {
  final Geometry g1;
  final Geometry g2;

  EmptyGeometryBuilder(
      Geometry this.g1, Geometry this.g2,
      GeometryFactory geomFactory,
      int overlayType) : super._(null, overlayType);

  List<Geometry> build() {
    var dim = _combineDims(_getDim(g1),_getDim(g2));
    return [_buildFromDim(dim)];
  }

  Geometry _buildFromDim(int dim) {
    if (overlayType == OVERLAY_UNION || overlayType == OVERLAY_SYMMETRIC_DIFFERENCE) {
      if (!g1.isEmptyGeometry) {
        return geomFactory.clone(g1);
      }
      if (!g2.isEmptyGeometry) {
        return geomFactory.clone(g2);
      }
    }
    switch (dim) {
      case 1:
        return geomFactory.createEmptyPoint();
      case 2:
        return geomFactory.createEmptyLinestring();
      case 3:
        return geomFactory.createEmptyPolygon();
    }
  }

  int _combineDims(int dim1, int dim2) {
    switch (overlayType) {
      case OVERLAY_INTERSECTION:
        return math.min(dim1, dim2);
      case OVERLAY_UNION:
        return math.max(dim1, dim2);
      case OVERLAY_DIFFERENCE:
        return math.min(dim1, dim2);
      case OVERLAY_SYMMETRIC_DIFFERENCE:
        return math.max(dim1, dim2);
    }
  }
}

bool _interiorOrBoundary(int location) => location == loc.INTERIOR || location == loc.BOUNDARY;

/**
 * test whether a location is in the overlay intersection
 */
bool _inIntersection(Tuple<int,int> onLocations) =>
    onLocations.both(_interiorOrBoundary);

/**
 *test whether a location is in the overlay union
 */
bool _inUnion(Tuple<int,int> onLocations) =>
    onLocations.either(_interiorOrBoundary);

/**
 * test whether a tuple of locations is in the overlay difference.
 * The left operand is assumed to be the location of the minuend geometry
 */
bool _inDifference(Tuple<int,int> onLocations) =>
    _interiorOrBoundary(onLocations.$1)
    && !_interiorOrBoundary(onLocations.$2);

/**
 * test whether a tuple of locations is in the overlay symmetric difference
 */
bool _inSymmetricDifference(Tuple<int,int> onLocations) =>
    onLocations.either(_interiorOrBoundary)
      && !onLocations.both(_interiorOrBoundary);


