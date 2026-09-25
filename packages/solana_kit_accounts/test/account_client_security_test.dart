import 'dart:async';
import 'dart:typed_data';

import 'package:solana_kit_accounts/solana_kit_accounts.dart';
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_spec/solana_kit_rpc_spec.dart';
import 'package:test/test.dart';

const _addressA = Address('GQE2yjns7SKKuMc89tveBDpzYHwXfeuB2PGAbGaPWc6G');
const _addressB = Address('11111111111111111111111111111111');

void main() {
  group('account response identity', () {
    for (final jsonParsed in [false, true]) {
      for (final responseKind in ['encoded', 'parsed', 'missing']) {
        if (!jsonParsed && responseKind == 'parsed') continue;

        test(
          '${jsonParsed ? 'jsonParsed' : 'base64'} keeps requested addresses '
          'with $responseKind responses when the input list changes',
          () async {
            final response = Completer<Object?>();
            final requested = Completer<List<String>>();
            final rpc = Rpc(
              api: MapRpcApi({
                'getMultipleAccounts': (params) => RpcPlan<Object?>(
                  execute: (config) {
                    requested.complete((params[0]! as List).cast<String>());
                    return response.future;
                  },
                ),
              }),
              transport: (config) async => null,
            );
            final addresses = [_addressA, _addressB];
            final client = createSolanaAccountClient(rpc);
            final pending = jsonParsed
                ? client.fetchJsonParsedAccounts(addresses)
                : client.fetchEncodedAccounts(addresses);

            expect(await requested.future, [_addressA.value, _addressB.value]);
            addresses
              ..clear()
              ..add(_addressB);
            response.complete({
              'value': [
                if (responseKind == 'missing')
                  null
                else
                  <String, Object?>{
                    'data': responseKind == 'parsed'
                        ? <String, Object?>{
                            'parsed': <String, Object?>{
                              'info': <String, Object?>{
                                'authority': 'account A',
                              },
                            },
                          }
                        : ['AQ==', 'base64'],
                    'executable': false,
                    'lamports': 1000,
                    'owner': _addressB.value,
                    'space': 1,
                  },
                null,
              ],
            });

            final accounts = await pending;
            expect(accounts.map((account) => account.address), [
              _addressA,
              _addressB,
            ]);
            expect(accounts[1].exists, isFalse);

            if (responseKind == 'encoded') {
              final first = accounts[0] as ExistingAccount<Uint8List>;
              expect(first.data, [1]);
            } else if (responseKind == 'parsed') {
              final first =
                  accounts[0]
                      as ExistingAccount<
                        JsonParsedAccountData<Map<String, Object?>>
                      >;
              expect(first.data.data, {'authority': 'account A'});
            } else {
              expect(accounts[0].exists, isFalse);
            }
          },
        );
      }
    }
  });
}
