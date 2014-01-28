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

class _LinestringBuilder extends _OverlayBuilder {
  _LinestringBuilder(graph, overlayType) : super._(graph, overlayType);

  Geometry build() {

    for (var fwdLabel in graph.forwardLabels.toList(growable:false)) {
      var onLocations = fwdLabel.locationDatas.map((l) => l.on);
      if (!_inOverlay(onLocations)) {
        graph.removeForwardEdge(fwdLabel);
      }
    }

    for (var bwdLabel in graph.backwardLabels.toList(growable:false)) {
      var onLocations = bwdLabel.locationDatas.map((l) => l.on);
      if (!_inOverlay(onLocations)) {
        graph.removeBackwardEdge(bwdLabel);
      }
    }

    if (graph.edges.isEmpty) {
      return geomFactory.createEmptyLinestring();
    }

    while (!graph.edges.isEmpty) {
      var edge = graph.edges.first;

    }
  }

  Linestring _buildLinestring() {
    DirectedEdge edge;
    if (graph.forwardEdges.isNotEmpty) {
      edge = graph.forwardEdges.first;
    } else if (graph.backwardEdges.isNotEmpty) {
      edge = graph.backwardEdges.first;
    }

    List<Coordinate> lstrCoords = new List.from((edge.label as EdgeLabel).coordinates);
    Node nextStart = edge.startNode;
    Node nextEnd = edge.endNode;
    while (true) {
      graph.removeEdge(edge.edge);
      if (nextStart == nextEnd) {
        //Looped node
        return geomFactory.createLinestring(lstrCoords);
      }
      if (nextStart != null) {
        var incomingStart = nextStart.incomingEdges;
      }
    }


  }
}