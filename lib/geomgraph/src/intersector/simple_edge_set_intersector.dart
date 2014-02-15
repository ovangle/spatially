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


part of spatially.geomgraph.intersector;

/**
 * Find all intersections in a set of edges
 * using the straightforward method of comparing
 * all segments
 */
IntersectionSet _simpleEdgeSetIntersector(List<Edge> edges,{ bool testAll: true }) {
  int nOverlaps = 0;
  IntersectionSet infos = new IntersectionSet();
  for (var e1 in edges) {
    for (var e2 in edges) {
      if (testAll || e1 != e2) {
        infos.addAll(_simpleIntersect(e1, e2));
      }
    }
  }
  return infos;
}

IntersectionSet _simpleIntersect(Edge e1, Edge e2) {
  IntersectionSet infos = new IntersectionSet._([]);
  for (var i in range(coordinateSegments(e1.coordinates).length)) {
    for (var j in range(coordinateSegments(e2.coordinates).length)) {
      var intersection = new IntersectionInfo(e1, i, e2, j);
      if (intersection != null) {
        infos.add(intersection);
      }
    }
  }
  return infos;
}