library geomgraph.label;

import 'dart:math' as math;
import 'package:quiver/core.dart';

import 'package:spatially/geom/location.dart' as loc;
import 'package:spatially/geom/base.dart';

/**
 * A [Label] is attached to a graph component and contains the represented
 * geometry and the locations around the given edge.
 */
abstract class Label {
  /**
   * The location on the graph component.
   */
  final int onLocation;
  /**
   * The location directly to the right of the graph component.
   * The value is only non-absent if the [Label] represents the edge
   * of a planar geometry.
   */
  Optional<int> get leftLocation => leftDepth.transform((depth) => depth == 0 ? loc.EXTERIOR : loc.INTERIOR) ;

  /**
   * The number of overlapping holes/regions on the left side of the geometry.
   * `0` indicates that the left is the exterior of the geometry.
   */
  Optional<int> get leftDepth;


  /**
   * The location directly to the right of the graph component.
   * The value is only non-absent if the [Label] represents the edge
   * of a planar geometry.
   */
  Optional<int> get rightLocation => rightDepth.transform((depth) => depth == 0 ? loc.EXTERIOR : loc.INTERIOR);

  /**
   * The number of overlapping holes/regions on the right side of the geometry.
   * `0` indicates that the right is the exterior of the geometry.
   */
  Optional<int> get rightDepth;

  /**
   * The [Geometry] which this graph component is an edge or node of.
   */
  final Geometry componentOf;

  Label._(this.componentOf, this.onLocation);

  factory Label(Geometry componentOf, int onLocation, {int leftLocation, int rightLocation}) {
    if (leftLocation != null || rightLocation != null) {
      if (rightLocation == null || leftLocation == null) {
        throw new ArgumentError("Either none, or both of leftLocation and rightLocation must be provided");
      }
      if (![loc.INTERIOR, loc.EXTERIOR].contains(leftLocation)) {
        throw new ArgumentError("left location must be one of loc.EXTERIOR or loc.INTERIOR");
      }
      //For a label which isn't the result of a merge, the maximum depth is initially 1.
      var leftDepth = leftLocation == loc.INTERIOR ? 1 : 0;
      var rightDepth = rightLocation == loc.INTERIOR ? 1 : 0;
      if (leftDepth != rightDepth) {
        return new _PlanarLabel(componentOf, onLocation, leftDepth, rightDepth);
      }
    }
    return new _LinearOrNodalLabel(componentOf, onLocation);
  }

  bool get isPlanar => leftLocation.isPresent;

  Label get flipped {
    if (isPlanar) {
      return new _PlanarLabel(componentOf, onLocation, (this as _PlanarLabel)._rightDepth, (this as _PlanarLabel)._leftDepth);
    }
    return this;
  }

  /**
   * Merges the two labels together to form a single label.
   * Merging a linear or nodal label with a planar label will return a planar label.
   */
  Label mergeWith(Label label) {
    if (!identical(componentOf, label.componentOf)) {
      throw new ArgumentError("Can only merge labels with identical geometries");
    }
    if (isPlanar) {
      return (this as _PlanarLabel)._mergeWith(label);
    }
    if (label.isPlanar) {
      return (label as _PlanarLabel)._mergeWith(this);
    }
    return this;
  }
}

class _LinearOrNodalLabel extends Label {
  _LinearOrNodalLabel(Geometry componentOf, int on) : super._(componentOf, on);

  Optional<int> get leftDepth => new Optional.absent();
  Optional<int> get rightDepth => new Optional.absent();
}

class _PlanarLabel extends Label {
  int _leftDepth;
  int _rightDepth;
  _PlanarLabel(Geometry componentOf, int on, int this._leftDepth, int this._rightDepth) :
    super._(componentOf, on) {
    _normalizeDepths();
  }
  Optional<int> get leftDepth => new Optional.of(_leftDepth);
  Optional<int> get rightDepth => new Optional.of(_rightDepth);

  void _normalizeDepths() {
    var minDepth = math.min(_leftDepth, _rightDepth);
    _leftDepth -= minDepth;
    _rightDepth -= minDepth;
  }

  Label _mergeWith(Label label) {
    label.leftDepth.ifPresent((depth) => _leftDepth += depth);
    label.rightDepth.ifPresent((depth) => _rightDepth += depth);
    _normalizeDepths();
    if (_leftDepth == _rightDepth) {
      return new _LinearOrNodalLabel(componentOf, onLocation);
    }
    return this;
  }
}

