import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

void main() {
  group('ParsedEventsClient', () {
    test(
      'parseTransactions posts the request and parses both statuses',
      () async {
        late http.Request captured;
        final client = MockClient((request) async {
          captured = request;
          return http.Response(
            jsonEncode([
              _parsedResult('sig-ok'),
              {
                'signature': 'sig-missing',
                'parserStatus': 'ERROR',
                'parserError': {
                  'code': 'transaction_not_found',
                  'message': 'not found',
                },
              },
            ]),
            200,
          );
        });
        final helius = createHelius(
          HeliusConfig(apiKey: 'test-key'),
          client: client,
        );

        final results = await helius.parsedEvents.parseTransactions(
          const ParseTransactionsRequest(
            transactions: ['sig-ok', 'sig-missing'],
            commitment: ParsedEventsCommitment.finalized,
            rawTransaction: ParsedEventsRawTransactionEncoding.base64,
          ),
        );

        expect(captured.method, 'POST');
        expect(captured.url.path, '/v1/parsed-events/transactions');
        expect(captured.url.queryParameters['api-key'], 'test-key');
        expect(jsonDecode(captured.body), {
          'transactions': ['sig-ok', 'sig-missing'],
          'commitment': 'finalized',
          'rawTransaction': 'base64',
        });

        expect(results, hasLength(2));
        expect(results[0].parserStatus, ParsedTransactionStatus.ok);
        expect(results[0].parsed!.slot, 100);
        expect(
          results[0].parsed!.transactionStatus,
          ParsedTransactionStatus.ok,
        );
        expect(results[0].parsed!.summary!.type, 'swap');
        expect(results[0].parsed!.nativeTransfers.single.amount, 1000);
        expect(results[0].parsed!.tokenTransfers.single.mint, 'mint-1');
        expect(results[0].parsed!.instructions.single.instructionName, 'route');
        expect(results[1].parserStatus, ParsedTransactionStatus.error);
        expect(results[1].parserError!.code, 'transaction_not_found');
      },
    );

    test('getTransactionHistory paginates and drops an empty cursor', () async {
      final bodies = <Map<String, Object?>>[];
      final client = MockClient((request) async {
        bodies.add(jsonDecode(request.body) as Map<String, Object?>);
        return http.Response(
          jsonEncode({
            'data': [_parsedResult('sig-1')],
            'paginationToken': 'next-page',
          }),
          200,
        );
      });
      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final response = await helius.parsedEvents.getTransactionHistory(
        const GetParsedTransactionHistoryRequest(
          address: 'address-1',
          limit: 50,
          paginationToken: '',
          status: ParsedEventsStatusFilter.any,
          tokenAccounts: ParsedEventsTokenAccountsFilter.balanceChanged,
          slot: ComparisonBounds(gte: 10, lt: 20),
          time: ComparisonBounds(gte: 1000),
        ),
      );

      expect(bodies.single['address'], 'address-1');
      expect(bodies.single['limit'], 50);
      expect(bodies.single.containsKey('paginationToken'), isFalse);
      expect(bodies.single['status'], 'any');
      expect(bodies.single['tokenAccounts'], 'balanceChanged');
      expect(bodies.single['slot'], {'gte': 10, 'lt': 20});
      expect(bodies.single['time'], {'gte': 1000});
      expect(response.data.single.signature, 'sig-1');
      expect(response.paginationToken, 'next-page');
    });

    test('scan sends match criteria and parses count responses', () async {
      late Map<String, Object?> body;
      final client = MockClient((request) async {
        body = jsonDecode(request.body) as Map<String, Object?>;
        return http.Response(
          jsonEncode({
            'scan': {
              'stoppedOn': 'budget',
              'scannedTransactions': 10000,
              'matchedTransactions': 7,
              'creditsCharged': 20,
              'scannedThrough': {'slot': 99, 'blockTime': 1700000000},
            },
            'paginationToken': 'scan-next',
          }),
          200,
        );
      });
      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      final response = await helius.parsedEvents.scan(
        const ScanParsedTransactionHistoryRequest(
          address: 'program-1',
          returnShape: ScanReturnShape.count,
          match: ScanMatch(
            programs: [
              ScanProgramMatch(
                programId: 'program-1',
                instructions: ['buy', 'sell'],
                scope: ScanMatchScope.transaction,
              ),
            ],
            mints: [ScanMintMatch(mint: 'mint-1')],
          ),
          budget: ScanBudget(maxScannedTransactions: 10000),
        ),
      );

      expect(body['address'], 'program-1');
      expect(body['returnShape'], 'count');
      expect(body['match'], {
        'programs': [
          {
            'programId': 'program-1',
            'instructions': ['buy', 'sell'],
            'scope': 'transaction',
          },
        ],
        'mints': [
          {'mint': 'mint-1'},
        ],
      });
      expect(body['budget'], {'maxScannedTransactions': 10000});
      expect(response.data, isNull);
      expect(response.scan.stoppedOn, ScanStopReason.budget);
      expect(response.scan.matchedTransactions, 7);
      expect(response.scan.creditsCharged, 20);
      expect(response.scan.scannedThrough!.slot, 99);
      expect(response.paginationToken, 'scan-next');
    });

    test('scan parses signature and transaction data by shape', () async {
      var responseJson = {
        'data': [
          {
            'signature': 'sig-1',
            'slot': 10,
            'transactionIndex': 1,
            'blockTime': 1700000000,
          },
        ],
        'scan': _scanSummary(),
      };
      final client = MockClient(
        (_) async => http.Response(jsonEncode(responseJson), 200),
      );
      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      var response = await helius.parsedEvents.scan(
        const ScanParsedTransactionHistoryRequest(
          address: 'address-1',
          returnShape: ScanReturnShape.signatures,
          match: ScanMatch(programs: [ScanProgramMatch(programId: 'p')]),
        ),
      );

      expect(response.signatures.single.signature, 'sig-1');
      expect(response.transactions, isEmpty);

      responseJson = {
        'data': [_parsedResult('sig-2')],
        'scan': _scanSummary(),
      };
      response = await helius.parsedEvents.scan(
        const ScanParsedTransactionHistoryRequest(
          address: 'address-1',
          match: ScanMatch(programs: [ScanProgramMatch(programId: 'p')]),
        ),
      );

      expect(response.transactions.single.signature, 'sig-2');
    });

    test('rejects devnet clients', () async {
      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key', cluster: HeliusCluster.devnet),
        client: MockClient((_) async => http.Response('[]', 200)),
      );

      expect(
        () => helius.parsedEvents.parseTransactions(
          const ParseTransactionsRequest(transactions: ['sig']),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'Parsed Events is only available on mainnet.',
          ),
        ),
      );
    });

    test('a per-call timeout rejects with TimeoutException', () async {
      final client = MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        return http.Response(jsonEncode([_parsedResult('sig-ok')]), 200);
      });
      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key'),
        client: client,
      );

      await expectLater(
        helius.parsedEvents.parseTransactions(
          const ParseTransactionsRequest(transactions: ['sig']),
          timeout: const Duration(milliseconds: 10),
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('the config timeout applies without a per-call override', () async {
      final client = MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        return http.Response(jsonEncode([_parsedResult('sig-ok')]), 200);
      });
      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key', parsedEventsTimeoutMs: 10),
        client: client,
      );

      await expectLater(
        helius.parsedEvents.getTransactionHistory(
          const GetParsedTransactionHistoryRequest(address: 'addr-1'),
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('a per-call timeout wins over the config default', () async {
      final client = MockClient((request) async {
        // Longer than the config limit but shorter than the per-call one.
        await Future<void>.delayed(const Duration(milliseconds: 60));
        return http.Response(jsonEncode([_parsedResult('sig-ok')]), 200);
      });
      final helius = createHelius(
        HeliusConfig(apiKey: 'test-key', parsedEventsTimeoutMs: 10),
        client: client,
      );

      final results = await helius.parsedEvents.parseTransactions(
        const ParseTransactionsRequest(transactions: ['sig']),
        timeout: const Duration(seconds: 5),
      );
      expect(results.single.signature, 'sig-ok');
    });

    test('a custom parsedEventsUrl host replaces the default', () async {
      late Uri capturedUrl;
      final client = MockClient((request) async {
        capturedUrl = request.url;
        return http.Response(
          jsonEncode(<String, Object?>{
            'data': <Object?>[],
            'paginationToken': null,
            'scan': _scanSummary(),
          }),
          200,
        );
      });
      final helius = createHelius(
        HeliusConfig(
          apiKey: 'test-key',
          parsedEventsUrl:
              'https://proxy.example.com/v1/parsed-events'
              '?tenant=one',
        ),
        client: client,
      );

      await helius.parsedEvents.scan(
        const ScanParsedTransactionHistoryRequest(
          address: 'addr-1',
          match: ScanMatch(),
          returnShape: ScanReturnShape.signatures,
        ),
      );

      expect(capturedUrl.host, 'proxy.example.com');
      expect(capturedUrl.path, '/v1/parsed-events/scan');
      // A proxy's own query string survives next to the api key.
      expect(capturedUrl.queryParameters['tenant'], 'one');
      expect(capturedUrl.queryParameters['api-key'], 'test-key');
    });
  });
}

Map<String, Object?> _parsedResult(String signature) => {
  'signature': signature,
  'parserStatus': 'OK',
  'parsed': {
    'slot': 100,
    'blockTime': 1700000000,
    'fee': 5000,
    'feePayer': 'payer',
    'transactionStatus': 'OK',
    'nativeTransfers': [
      {'fromUserAccount': 'a', 'toUserAccount': 'b', 'amount': 1000},
    ],
    'tokenTransfers': [
      {
        'fromUserAccount': 'a',
        'toUserAccount': 'b',
        'fromTokenAccount': 'ta',
        'toTokenAccount': 'tb',
        'rawTokenAmount': 100,
        'decimals': 6,
        'tokenStandard': 'Fungible',
        'mint': 'mint-1',
      },
    ],
    'summary': {
      'type': 'swap',
      'description': 'Swapped tokens',
      'parsedData': {'protocol': 'jupiter'},
    },
    'instructions': [
      {
        'instructionIndex': 0,
        'innerInstructionIndex': null,
        'stackHeight': 1,
        'programId': 'program-1',
        'rawAccounts': ['a', 'b'],
        'rawData': 'data',
        'summary': null,
        'programName': 'jupiter',
        'instructionName': 'route',
        'decoded': {
          'args': {'amount': '100'},
          'accounts': [
            {
              'name': 'user',
              'pubkey': 'a',
              'isSigner': true,
              'isWritable': true,
            },
          ],
        },
      },
    ],
  },
};

Map<String, Object?> _scanSummary() => {
  'stoppedOn': 'windowEnd',
  'scannedTransactions': 10,
  'matchedTransactions': 1,
  'creditsCharged': 11,
};
