part of algorithms;


/**
 * An implementation of the Bentley-Ottman algorithm
 * for determining the intersection points in a set of line segments.
 * 
 * Two segments are intersecting if they approach within the distance [:tolerance:]
 * of each other.
 * If [:includeEndpoints:] is `false`, intersections which contain only the start of
 * one segment and the end of another are ignored.
 */
MultiGeometry bentleyOttmanIntersections(Set<LineSegment> lineSegments, 
                                      {double tolerance: 1e-15,
                                       Iterable<Point> ignoredAdjacencies: const []}) {
  
  //The result set.
  MultiGeometry intersections = new MultiGeometry();
  
  //A new priority queue, with priority based on the longitude of the map key
  //and on the type of the event. 
  _EventQueue eventQueue = new _EventQueue(tolerance);

  /*
   * For each segment in the list, record an endpoint event for each end of the segment
   */
  for (var seg in lineSegments) {
    eventQueue.futureLeftEndpointEvent(seg);
    eventQueue.futureRightEndpointEvent(seg); 
  }
  
  //A search tree mapping points to linesegments.
  _Sweepline sweepline = new _Sweepline(tolerance);
  
  List<Map<String, dynamic>> handledCrossings = [];
  
  bool evtHandled(Map<String,dynamic> evtData) {
    return handledCrossings.any(
        (m) => m["intersection"] == evtData["intersection"]
            && m["segment1"] == evtData["segment1"]
            && m["segment2"] == evtData["segment2"]);
  }
  
  int iterCount = 0;
  while (eventQueue.isNotEmpty) {
    /*
    util.IFDEF_DEBUG(() { 
      print("Iteration: $iterCount");
      print('\tEvent queue: ');
      for (var k in eventQueue.keys) {
        print("\t\t$k: ${eventQueue[k]}");
      }
      print("\tSegment tree: ");
      for (var k in sweepline.keys) {
        print("\t\t$k: ${sweepline[k]}");
      }
      print("\tIntersections: ");
      for (var isectPoint in intersections) {
        print("\t\t$isectPoint");
      }
    }); //#endif
    */
    iterCount += 1;
    
    // Pop the next event
    final p = eventQueue.firstKey();
    Map evtData = eventQueue.remove(p);
    
    // And process it.
    final evtLocation = p.item1;
    //print("\tSweep line location: $evtLocation");
    switch(p.item2) {
      case _EventQueue.LEFT_ENDPOINT_EVT:
        // When the search line crosses the left endpoint of a line segment,
        // Add the segment to the search tree
        //             S
        //             |
        //        C    |
        //         \   |       B
        //          \  |      /
        //     A-----\-|-----/------------------A
        //            \|    /
        //             \   /
        //             |\ /
        //             | X
        //             |/ \ 
        //             B   \   
        //             |    C
        //             |
        //             S
        // Here we would add segment B to the search tree.
        final evtSegment = evtData["segment"];
        sweepline[evtSegment] = evtSegment;
       
        // After adding the segment to the search tree, check whether
        // the elements that are directly above or directly below
        // it intersect it in the future.
        final r = sweepline.segmentAbove(evtSegment);
        if (r != null) {
          eventQueue.futureCrossingEvent(evtSegment, r, ignoredAdjacencies);
        }
        final t = sweepline.segmentBelow(evtSegment);
        if (t != null) {
          eventQueue.futureCrossingEvent(evtSegment, t, ignoredAdjacencies);
        }
        continue;
        
      case _EventQueue.RIGHT_ENDPOINT_EVT:
        //If we're at a right endpoint, delete tne segment
        //                  S
        //                  |
        //        C         |
        //         \        |  B
        //          \       | /
        //     A-----\------|/------------------A
        //            \     |
        //             \   /|
        //              \ / |                 
        //               X  |                                  
        //              / \ |                                 
        //             B   \|   
        //                  C
        //                  |
        //                  S
        //    Here we would delete segment C
          
        final evtSegment = evtData["segment"];
        
        
        
        final r = sweepline.segmentBelow(evtSegment);
        final t = sweepline.segmentAbove(evtSegment);
        sweepline.removeSegment(evtSegment);
        // After removing the segment from the search tree,
        // Check to see whether the segments that were directly
        // below and above the line intersect in the future.
        if (r != null && t != null) {
           eventQueue.futureCrossingEvent(r,t, ignoredAdjacencies);
        }
        continue;
      case _EventQueue.CROSSING_EVT:
        // When the search line crosses an intersection point
        // in the queue, record the intersection in our return
        // values.
        //           S
        //           |
        //        C  |
        //         \ |         C
        //          \|        /
        //     A-----|-------/------------------A
        //           |\     /
        //           | \   /
        //           |  \ /
        //           |   X
        //           |  / \ 
        //           | B   \   
        //           |      C
        //           |
        //           S
        // Here we would record the intersection of C and A
        if (evtHandled(evtData)) continue;
        handledCrossings.add(evtData);
        final intersection = evtData["intersection"];
        if (!intersections.contains(intersection)
            && (intersection is! LineSegment 
                || !intersections.contains(intersection.reversed)
            )) {
          intersections = intersections.add(evtData["intersection"]);
        }
        
        final evtSegment1 = evtData["segment1"];
        final evtSegment2 = evtData["segment2"];
        
        //seg1 is below seg2 to the left of the crossing
        assert(evtSegment1.left.y <= evtSegment2.left.y);
        
        // In the past C was above A in the search tree, but now
        // A is below C. Correct the search tree by swapping the 
        // positions of C and A in the tree.
        sweepline.swap(evtSegment1, evtSegment2);

        // Check the segment directly above the new top segment for an intersection
        final r = sweepline.segmentAbove(evtSegment1);
        if (r != null)
          eventQueue.futureCrossingEvent(r, evtSegment1, ignoredAdjacencies);
        
        // The segment directly below the new top segment
        final s = sweepline.segmentBelow(evtSegment1);
        if (s != null)
          eventQueue.futureCrossingEvent(s, evtSegment1, ignoredAdjacencies);
        
        // And the segment directly below the new bottom segment
        final u = sweepline.segmentBelow(evtSegment2);
        if (u != null) 
          eventQueue.futureCrossingEvent(u, evtSegment2, ignoredAdjacencies);
        
        // Finally, the segment directly above the new bottom segment
        final v = sweepline.segmentAbove(evtSegment2);
        if (v != null) 
          eventQueue.futureCrossingEvent(v, evtSegment2, ignoredAdjacencies);
        continue;
    }
  }
  return intersections;
}

class _EventQueue extends SplayTreeMap<Tuple3<Point,int,int>, Map<String,dynamic>> {
  /**
   * An event which is fired when the sweep line crosses a left endpoint
   */
  static const int LEFT_ENDPOINT_EVT = 0;
  /**
   * An event which is fired when the sweep line crosses the intersection
   * between two line segments
   */
  static const int CROSSING_EVT = 1;
  /**
   * An event which is fired when the sweep line crosses a right endpoint
   */
  static const int RIGHT_ENDPOINT_EVT = 2;
  static Comparator<Tuple3<Point, int, int>> _compareKeys(double tolerance) {
    return (k1, k2) {
      /* Event queue keys are sorted first by the x-coordinate of the first item in the tuple.
       *  then by the type of the event and finally by the y-coordinate of the event
       * 
       * The type of the event is sorted such that:
       *  - Left endpoint events are sorted before crossing events
       *  - Crossing events are sorted before Right endpoint events
       */
      var cmp_x = util.compareDoubles(k1.item1.x, k2.item1.x, tolerance);
      if (cmp_x != 0) return cmp_x;
      var cmp_type = Comparable.compare(k1.item2, k2.item2);
      if (cmp_type != 0) return cmp_type;
      var cmp_y  = util.compareDoubles(k1.item1.y, k2.item1.y, tolerance);
      if (cmp_y != 0) return cmp_y;
      var cmp_keys = Comparable.compare(k1.item3, k2.item3);
      return cmp_keys;
    };
  }
  
  /**
   * The tolerance to use when comparing keys in the event queue.
   * Also used when creating future crossing events
   */
  final double tolerance;
  
  _EventQueue(double _tolerance) : super(_compareKeys(_tolerance)),
                                  this.tolerance = _tolerance;
  
  Tuple3<Point,int,int> _newKey(Point evtLocation, int evtType) {
    final maxKey = keys.lastWhere(
        (k) => k.item1 == evtLocation && k.item2 == evtType, 
        orElse: () => null);
    return new Tuple3(
        evtLocation,
        evtType,
        maxKey != null ? maxKey.item3 + 1 : 0);
  }
  
  void futureLeftEndpointEvent(LineSegment lseg) {
    final evtKey = _newKey(lseg.left, LEFT_ENDPOINT_EVT);
    this[evtKey] = { "segment" : lseg };
  }
  
  void futureRightEndpointEvent(LineSegment lseg) {
    final evtKey = _newKey(lseg.right, RIGHT_ENDPOINT_EVT);
    this[evtKey] = { "segment" : lseg };
  }
  
  void futureCrossingEvent(LineSegment lseg1, 
                           LineSegment lseg2, 
                           Iterable<Point> ignoredAdjacencies) {
    final intersection = lseg1.intersection(lseg2);
    //Don't record a crossing 
    if (intersection == null) return;
    Map evtData = new Map();
    evtData["intersection"] = intersection;
    //seg1 will always be below seg2 to the left of the crossing
    evtData["segment1"] = lseg1.left.y < lseg2.left.y ? lseg1 : lseg2;
    evtData["segment2"] = lseg1.left.y < lseg2.left.y ? lseg2 : lseg1;
    if (intersection is Point) {
      if (ignoredAdjacencies.contains(intersection)
            && [lseg1.start, lseg1.end].contains(intersection)
            && [lseg2.start, lseg2.end].contains(intersection)) {
          return;
      }
      final evtKey = _newKey(intersection, CROSSING_EVT);
      this[evtKey] = evtData;
    } else if (intersection is LineSegment) {
      final evtKey = _newKey(intersection.left, CROSSING_EVT);
      this[evtKey] = evtData;
    }
  }
}

class _Sweepline extends SplayTreeMap<LineSegment, LineSegment> {
  static Comparator<LineSegment> _compareKeys(double tolerance) {
    return (k1, k2) {
      final cmp_1y = util.compareDoubles(k1.left.y, k2.left.y, tolerance);
      if (cmp_1y != 0) return cmp_1y;
      //Negate the x comparisons, because if the x-coordinate is larger when the y is smaller,
      //the segment will be below the other key
      final cmp_1x = -util.compareDoubles(k1.left.x, k2.left.x, tolerance);
      if (cmp_1x != 0) return cmp_1x;
      //If the left point points are equal, compare by the right points
      final cmp_2y = util.compareDoubles(k1.right.y, k2.right.y, tolerance);
      if (cmp_2y != 0) return cmp_2y;
      final cmp_2x = -util.compareDoubles(k1.right.x, k2.right.x, tolerance);
      if (cmp_2x != 0) return cmp_2x;
      //The final case is if the lines are equal, but reversed. Since always
      //taking the left and right endpoints above, lines which are equal at both
      //endpoints but which point in opposite directions get dropped
      //Since we know that the start of one segment is equal to the end of the other
      //only the start needs to be checked.
      final cmp_diry = util.compareDoubles(k1.start.y, k2.start.y, tolerance);
      if (cmp_diry != 0) return cmp_diry;
      return -util.compareDoubles(k1.start.x, k2.start.x, tolerance);
    };
  }
  _Sweepline(double tolerance) : super(_compareKeys(tolerance));
  
  LineSegment keyOf(LineSegment lseg) => keys.singleWhere((k) => this[k] == lseg);
  /**
   * Swap the position of two line segments in the sweepline.
   */
  void swap(LineSegment lseg1, LineSegment lseg2) {
    final k1 = keyOf(lseg1); final k2 = keyOf(lseg2);
    final t = this[k1];
    this[k1] = this[k2];
    this[k2] = t;
  }
  
 
  LineSegment removeSegment(LineSegment lseg) => remove(keyOf(lseg));
  /**
   * The segment directly below [:lseg:] in the sweepline
   */
  LineSegment segmentBelow(LineSegment lseg) {
    final k = lastKeyBefore(keyOf(lseg));
    return (k != null) ? this[k] : null;
  }
  /**
   * The segment directly above [:lseg:] in the sweepline
   */
  LineSegment segmentAbove(LineSegment lseg) {
    var k = firstKeyAfter(keyOf(lseg));
    return (k != null) ? this[k] : null;
  }
}

