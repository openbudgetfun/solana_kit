// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_mobile_wallet_adapter/solana_kit_mobile_wallet_adapter.dart';

Future<void> main() async {
  final request = AuthorizeDappRequest.fromParams(
    requestId: 'req-1',
    sessionId: 'session-1',
    params: {
      'identity': {
        'name': 'Example dApp',
        'uri': 'https://example.com',
      },
      'chain': 'solana:mainnet',
    },
  )..completeWithAuthorize(
      accounts: const [
        AuthorizedAccount(
          address: 'dGVzdA==',
          label: 'Primary Account',
        ),
      ],
      authToken: 'example-token',
    );

  final response = await request.future;
  print('Wallet authorize response: $response');
}
