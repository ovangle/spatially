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


/**
 * Utilities for dealing with iterables.
 */
//TODO: Remove if my PR is accepted into quiver.
library spatially.base.iterables;

import 'dart:collection';
import 'package:quiver/core.dart' show Optional;
import 'tuple.dart';

part 'src/iterables/groupby.dart';
part 'src/iterables/group_join.dart';
part 'src/iterables/slice.dart';

class Group<K,E>
extends Object with IterableMixin<E>
implements Iterable<E> {
  final K key;
  final Iterable<E> values;

  Group(this.key, this.values);
  Iterator<E> get iterator => values.iterator;
  String toString() => "($key: $values)";
}