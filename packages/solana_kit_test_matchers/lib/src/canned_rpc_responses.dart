import 'package:solana_kit_addresses/solana_kit_addresses.dart';

/// Returns a canned `getBalance` result payload.
Map<String, Object?> getBalanceRpcResult({
  BigInt? slot,
  BigInt? lamports,
}) {
  return {
    'context': {'slot': slot ?? BigInt.one},
    'value': lamports ?? BigInt.zero,
  };
}

/// Returns a canned `getAccountInfo` result payload.
Map<String, Object?> getAccountInfoRpcResult({
  BigInt? slot,
  Map<String, Object?>? value,
}) {
  return {
    'context': {'slot': slot ?? BigInt.one},
    'value': value,
  };
}

/// Returns a canned `getSlot` result payload.
BigInt getSlotRpcResult({BigInt? slot}) => slot ?? BigInt.one;

/// Returns a canned `getLatestBlockhash` result payload.
Map<String, Object?> getLatestBlockhashRpcResult({
  BigInt? slot,
  String blockhash = 'J4yED2jcMAHyQUg61DBmm4njmEydUr2WqrV9cdEcDDgL',
  BigInt? lastValidBlockHeight,
}) {
  return {
    'context': {'slot': slot ?? BigInt.one},
    'value': {
      'blockhash': blockhash,
      'lastValidBlockHeight': lastValidBlockHeight ?? BigInt.two,
    },
  };
}

/// Returns a canned `getSignatureStatuses` result payload.
Map<String, Object?> getSignatureStatusesRpcResult({
  BigInt? slot,
  List<Object?> statuses = const <Object?>[null],
}) {
  return {
    'context': {'slot': slot ?? BigInt.one},
    'value': statuses,
  };
}

/// Returns a canned `sendTransaction` result payload.
String sendTransactionRpcResult({
  String signature =
      '3bwsNoq6EP89sShUAKBeB26aCC3KLGNajRm5wqwr6zRPP3gErZH7erSg3332SVY7Ru6cME43qT35Z7JKpZqCoPaL',
}) => signature;

/// Returns a canned `requestAirdrop` result payload.
String requestAirdropRpcResult({
  String signature =
      '3bwsNoq6EP89sShUAKBeB26aCC3KLGNajRm5wqwr6zRPP3gErZH7erSg3332SVY7Ru6cME43qT35Z7JKpZqCoPaL',
}) => signature;

/// Returns a canned `getEpochInfo` result payload.
Map<String, Object?> getEpochInfoRpcResult({
  BigInt? absoluteSlot,
  BigInt? blockHeight,
  BigInt? epoch,
  BigInt? slotIndex,
  BigInt? slotsInEpoch,
  BigInt? transactionCount,
}) {
  return {
    'absoluteSlot': absoluteSlot ?? BigInt.one,
    'blockHeight': blockHeight ?? BigInt.one,
    'epoch': epoch ?? BigInt.zero,
    'slotIndex': slotIndex ?? BigInt.zero,
    'slotsInEpoch': slotsInEpoch ?? BigInt.from(432000),
    'transactionCount': transactionCount ?? BigInt.zero,
  };
}

/// Returns a minimal canned `getTransaction` result payload.
Map<String, Object?> getTransactionRpcResult({
  String blockhash = 'J4yED2jcMAHyQUg61DBmm4njmEydUr2WqrV9cdEcDDgL',
  String recentBlockhash = 'J4yED2jcMAHyQUg61DBmm4njmEydUr2WqrV9cdEcDDgL',
  Address feePayer = const Address('11111111111111111111111111111111'),
}) {
  return {
    'slot': BigInt.one,
    'transaction': {
      'message': {
        'accountKeys': [feePayer.value],
        'header': {
          'numReadonlySignedAccounts': 0,
          'numReadonlyUnsignedAccounts': 0,
          'numRequiredSignatures': 1,
        },
        'instructions': const <Object?>[],
        'recentBlockhash': recentBlockhash,
      },
      'signatures': const <Object?>[
        '3bwsNoq6EP89sShUAKBeB26aCC3KLGNajRm5wqwr6zRPP3gErZH7erSg3332SVY7Ru6cME43qT35Z7JKpZqCoPaL',
      ],
    },
    'meta': null,
    'blockTime': BigInt.one,
    'version': 'legacy',
    'blockhash': blockhash,
  };
}
