library spatially.geomgraph.geometry_graph.all_tests;

import 'add_test.dart' as add;
import 'edge_splitting_test.dart' as edge_splitting;
import 'graph_noding_test.dart' as graph_noding;
import 'graph_labelling_test.dart' as graph_labelling;
void main() {
  add.main();
  edge_splitting.main();
  graph_noding.main();
  graph_labelling.main();
}