import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';

/// Creates an [Account] test fixture.
Account<TData> createAccountFixture<TData>({
  required Address address,
  required TData data,
  bool executable = false,
  Lamports? lamports,
  Address programAddress = const Address('11111111111111111111111111111111'),
  BigInt? space,
}) {
  return Account<TData>(
    address: address,
    data: data,
    executable: executable,
    lamports: lamports ?? Lamports(BigInt.zero),
    programAddress: programAddress,
    space: space ?? BigInt.zero,
  );
}

/// Creates an existing encoded account fixture.
ExistingAccount<Uint8List> createExistingEncodedAccountFixture({
  required Address address,
  Uint8List? data,
  bool executable = false,
  Lamports? lamports,
  Address programAddress = const Address('11111111111111111111111111111111'),
}) {
  return ExistingAccount<Uint8List>(
    createAccountFixture<Uint8List>(
      address: address,
      data: data ?? Uint8List(0),
      executable: executable,
      lamports: lamports,
      programAddress: programAddress,
      space: BigInt.from(data?.length ?? 0),
    ),
  );
}

/// Creates a missing encoded account fixture.
NonExistingAccount<Uint8List> createMissingEncodedAccountFixture(
  Address address,
) {
  return NonExistingAccount<Uint8List>(address);
}
