/// Downcasts a [BigInt] value to a [num] (specifically an [int]).
///
/// If the value is not a [BigInt], it is returned as-is.
Object? downcastNodeToNumberIfBigint(Object? value, _) {
  if (value is BigInt) {
    return value.toInt();
  }
  return value;
}
