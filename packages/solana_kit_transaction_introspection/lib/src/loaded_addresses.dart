import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// Loaded ALT addresses as returned by `getTransaction`'s
/// `meta.loadedAddresses`.
///
/// The two lists are kept in the same order the runtime uses to resolve
/// instruction account indices.
class LoadedAddresses {
  /// Creates a [LoadedAddresses] with the given readonly and writable
  /// addresses.
  const LoadedAddresses({
    this.readonly = const [],
    this.writable = const [],
  });

  /// ALT-loaded readonly account addresses, in runtime resolution order.
  final List<Address> readonly;

  /// ALT-loaded writable account addresses, in runtime resolution order.
  final List<Address> writable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadedAddresses &&
          _listEquals(readonly, other.readonly) &&
          _listEquals(writable, other.writable);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(readonly), Object.hashAll(writable));

  @override
  String toString() =>
      'LoadedAddresses(readonly: $readonly, writable: $writable)';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
