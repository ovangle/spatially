library geomgraph.geomgraph;


import 'base.dart';
import '../base/coordinate.dart';

import 'package:spatially/algorithm/coordinate_locator.dart' as pt_loc;
/**
  * A graph which models a given [Geometry]
  */
class GeomGraph {
  List<Node> boundaryNodes;
  bool tooFewPoints = false;
  Coordinate invalidPoints = null;
  
}