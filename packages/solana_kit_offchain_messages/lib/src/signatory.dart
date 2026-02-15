import 'package:meta/meta.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// Represents an address that is required to sign an offchain message.
@immutable
class OffchainMessageSignatory {
  /// Creates a signatory with the given [address].
  const OffchainMessageSignatory({required this.address});

  /// The address of the signatory.
  final Address address;

  @override
  bool operator ==(Object other) {
    return other is OffchainMessageSignatory &&
        other.address.value == address.value;
  }

  @override
  int get hashCode => address.value.hashCode;
}
