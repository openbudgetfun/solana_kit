import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_parsed_types/src/rpc_parsed_type.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Parsed account data for a BPF Upgradeable Loader program account.
///
/// This is a discriminated union that can be either a [JsonParsedBpfProgram]
/// ('program') or a [JsonParsedBpfProgramData] ('programData').
sealed class JsonParsedBpfUpgradeableLoaderProgramAccount {
  const JsonParsedBpfUpgradeableLoaderProgramAccount();
}

/// A parsed BPF Upgradeable Loader 'program' variant.
class JsonParsedBpfProgram
    extends RpcParsedType<String, JsonParsedBpfProgramInfo>
    implements JsonParsedBpfUpgradeableLoaderProgramAccount {
  /// Creates a new [JsonParsedBpfProgram].
  const JsonParsedBpfProgram({required super.info}) : super(type: 'program');
}

/// The info payload for a parsed BPF program account.
class JsonParsedBpfProgramInfo {
  /// Creates a new [JsonParsedBpfProgramInfo].
  const JsonParsedBpfProgramInfo({required this.programData});

  /// The address of the program data account.
  final Address programData;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonParsedBpfProgramInfo &&
          runtimeType == other.runtimeType &&
          programData == other.programData;

  @override
  int get hashCode => Object.hash(runtimeType, programData);

  @override
  String toString() =>
      'JsonParsedBpfProgramInfo(programData: $programData)';
}

/// A parsed BPF Upgradeable Loader 'programData' variant.
class JsonParsedBpfProgramData
    extends RpcParsedType<String, JsonParsedBpfProgramDataInfo>
    implements JsonParsedBpfUpgradeableLoaderProgramAccount {
  /// Creates a new [JsonParsedBpfProgramData].
  const JsonParsedBpfProgramData({required super.info})
    : super(type: 'programData');
}

/// The info payload for a parsed BPF program data account.
class JsonParsedBpfProgramDataInfo {
  /// Creates a new [JsonParsedBpfProgramDataInfo].
  const JsonParsedBpfProgramDataInfo({
    required this.data,
    required this.slot,
    this.authority,
  });

  /// The optional upgrade authority address.
  final Address? authority;

  /// The program data as a base64-encoded data response.
  final Base64EncodedDataResponse data;

  /// The slot at which the program was last deployed or upgraded.
  final Slot slot;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonParsedBpfProgramDataInfo &&
          runtimeType == other.runtimeType &&
          authority == other.authority &&
          data == other.data &&
          slot == other.slot;

  @override
  int get hashCode => Object.hash(runtimeType, authority, data, slot);

  @override
  String toString() =>
      'JsonParsedBpfProgramDataInfo(authority: $authority, data: $data, '
      'slot: $slot)';
}
