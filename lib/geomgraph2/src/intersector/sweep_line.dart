part of spatially.geomgraph.intersector;

/**
 * A sweep line algorithm is one which moves an infinite
 * horizontal line across the plane in the positive x-direction,
 * recording events as it passes over them.
 */
class SweeplineEvent implements Comparable<SweeplineEvent> {
  static const int INSERT_EVT = 0;
  static const int DELETE_EVT = 1;
  /**
   * A reference to the insert event (for delete events).
   * If this is an insertion, the result will be null.
   */
  final SweeplineEvent _insertEvt;
  /* One of INSERT_EVT | DELETE_EVT */
  int get evtType =>
      _insertEvt == null ? INSERT_EVT : DELETE_EVT;
  List<Edge> edgeSet;
  /**
   * The position along the x-axis at which
   * the event will occur.
   */
  final double sweepLinePosition;
  final MonotoneChain mchain;

  SweeplineEvent.insertEvent(double this.sweepLinePosition,
                             this.edgeSet,
                             this.mchain) :
      _insertEvt = null;

  SweeplineEvent.deleteEvent(double this.sweepLinePosition,
                             SweeplineEvent insertEvent) :
      _insertEvt = insertEvent,
      edgeSet = insertEvent.edgeSet,
      mchain  = insertEvent.mchain;

  /**
   * SweepLineEvents are sorted first by their position
   * along the x-axis and then by the event type, with
   * INSERT events being processed before DELETE events.
   */
  int compareTo(SweeplineEvent evt) {
    var cmpPos = sweepLinePosition.compareTo(evt.sweepLinePosition);
    if (cmpPos != 0) return cmpPos;
    return evtType.compareTo(evt.evtType);
  }
}