library shared;

class Enum {
  final int asInt;
  
  const Enum._(this.asInt);
  
  bool operator ==(Object o) {
    return o.runtimeType == runtimeType
        && (o as Enum).asInt == asInt;
  }
  
  int get hashCode => 
      17 * (runtimeType.hashCode + asInt.hashCode + 1);
}