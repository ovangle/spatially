part of algorithms;


/**
 * A sweepline algorithm, which threads a sequence of [Linear] geometries
 * together into a single line.
 */
Linestring threadLinear(List<Linear> lines) {
  var l = lines.removeLast();
  var currStart = l.start;
  var currEnd   = l.end;
  var result = [];
  while(lines.isNotEmpty) {
    var toRemove = [];
    for (var i = 0;i<lines.length; i++) {
      if (lines[i].end.equalTo(currStart)) {
        result.insert(0, lines[i]);
        toRemove.add(i);
        currStart = lines[i].start;
      }
      if (lines[i].start.equalTo(currStart)) {
        result.insert(0, lines[i].reversed);
        toRemove.add(i);
        currStart = lines[i].end;
      }
      if (lines[i].start.equalTo(currStart)) {
        result.add(lines[i]);
        toRemove.add(i);
        currEnd = lines[i].end;
      }
      if (lines[i].end.equalTo(currStart)) {
        result.add(lines[i].reversed);
        toRemove.add(i);
        currEnd = lines[i].start;
      }
    }
    for (var j in toRemove) {
      lines.removeAt(j);
    }
  }
  result = result.expand((l) => l.toLinestring());
  return new Linestring(result);
}

