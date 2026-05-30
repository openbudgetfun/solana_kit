import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_config/src/generated/instructions/store.dart';
import 'package:solana_kit_config/src/generated/programs/solana_config.dart';
import 'package:solana_kit_config/src/generated/types/config_keys.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';

/// Creates a typed Config program `Store` instruction.
///
/// The [configData] bytes are written to [configAccount]. The [keys] list is
/// encoded into the config account and signer keys from that list must also be
/// supplied as transaction accounts. If [signers] is omitted, it is derived from
/// every [ConfigKey] where `isSigner` is true.
Instruction getStoreConfigInstruction({
  required Address configAccount,
  required ConfigKeys keys,
  required Uint8List configData,
  List<Address>? signers,
  bool configAccountIsSigner = false,
  Address programAddress = solanaConfigProgramAddress,
}) {
  return getStoreInstruction(
    configAccount: configAccount,
    keys: keys,
    data: configData,
    signers: signers ?? _signerAddresses(keys),
    configAccountIsSigner: configAccountIsSigner,
    programAddress: programAddress,
  );
}

List<Address> _signerAddresses(ConfigKeys keys) => [
  for (final key in keys)
    if (key.isSigner) key.address,
];
