library geomgraph.label;


import 'package:spatially/geom/location.dart' as loc;
import 'package:spatially/geom/base.dart';

part 'src/label/relationship_attribute.dart';

abstract class Label {
  final Geometry componentOf;
  Label._(Geometry this.componentOf);
  
  factory Label.nodeLabel(Geometry componentOf, int onLocation) {
    return new NodalLabel._(componentOf, onLocation);
  }
  
  factory Label.linearLabel(Geometry componentOf, int onLocation) {
    return new LinearLabel._(componentOf, onLocation);
  }
  
  factory Label.planarLabel(Geometry componentOf, 
                            {int onLoc,
                             int leftLoc,
                             int rightLoc}) {
    return new PlanarLabel._(componentOf, onLoc, leftLoc, rightLoc);
  }
  
  /**
   * The location on the geometry represented by the labelled graph
   * component
   */
  int get onLocation;
}

class NodalLabel extends Label {
  final int onLocation;
  
  NodalLabel._(Geometry componentOf, int this.onLocation) :
    super._(componentOf);
}

class LinearLabel extends Label {
  final int onLocation;
  
  LinearLabel._(Geometry componentOf, int this.onLocation) :
    super._(componentOf);
}

class PlanarLabel extends Label {
  final int onLocation;
  /**
   * The location to the left of the [Ring] represented by the 
   * labelled edge
   */
  final int leftLocation;
  /**
   * The location to the right of the [Ring] represented by
   * the labelled edge.
   */
  final int rightLocation;
  
  PlanarLabel._(Geometry componentOf, 
                 int this.onLocation, 
                 int this.leftLocation,
                 int this.rightLocation) :
    super._(componentOf);
}

