library noding.validator;

import 'package:quiver/iterables.dart';
import 'package:spatially/base/coordinate.dart';

import 'exception.dart';


class NodingValidator {
  final List<List<Coordinate>> _coordLists;
  /**
   * A key value store of the context in which the validation
   * was performed.
   */
  final Map<String,dynamic> context;

  NodingValidator(Iterable<Iterable<Coordinate>> coordLists,
                  { Map<String, dynamic> context: const {} }) :
    _coordLists = new List.from(
        coordLists.map((cs) => cs.toList(growable: false)),
        growable: false),
    this.context = context;


  void validateCollapses() {
    /**
     * A triple of three adjacent coordinates is collapsed
     * if it forms an a-b-a triple. The resulting linestring
     * would have folded back on itself.
     */
    bool isCollapsed(Coordinate c0, Coordinate c1, Coordinate c2) {
      return c0 == c2;
    }

    for (var coords in _coordLists) {
      for (var i in range(2, coords.length)) {
        if (isCollapsed(coords[i - 2], coords[i-1], coords[i])) {
          throw new NodingException.collapseAt(coords[i - 2]);
        }
      }
    }
  }

  /**
   * Checks that no two pairs of segments in the coordinate
   * lists have interior intersections.
   */
  void checkInteriorIntersections() {
    for (var coords1 in _coordLists) {
      for (var coords2 in _coordLists) {


      }
    }
  }




}