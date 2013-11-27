library geomgraph.node;

import 'dart:collection';

import 'package:spatially/base/coordinate.dart';
import 'package:spatially/geom/location.dart' as loc;
import 'label.dart';

part 'src/node/node_map.dart';

/**
 * Typedef for methods which create [Node]s
 */
typedef Node NodeFactory(Coordinate coord);

const NodeFactory DEFAULT_NODE_FACTORY = _defaultNodeFactory;
_defaultNodeFactory(c) => new Node(c);

class Node {
  final Coordinate coordinate;
  Label label;
  
  Node(Coordinate this.coordinate);
  
}