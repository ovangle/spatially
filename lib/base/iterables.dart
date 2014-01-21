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