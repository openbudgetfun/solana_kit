import 'dart:convert';
import 'dart:typed_data';

import 'package:solana_kit_dapp_publisher_cli/src/attestation.dart';
import 'package:solana_kit_dapp_publisher_cli/src/errors.dart';
import 'package:solana_kit_dapp_publisher_cli/src/funding_preflight.dart';
import 'package:solana_kit_dapp_publisher_cli/src/publication_signer.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

final KeyPair keyPair = generateKeyPair();
final signer = LocalPublicationSigner(keyPair);

void main() {
  group('createAttestationPayload', () {
    test('builds a signed payload with the expected request id', () async {
      final attestation = await createAttestationPayload(
        (slot: 100, blockhash: 'Bh'),
        signer,
        requestIdGenerator: () => '1234567890',
      );
      expect(attestation.requestUniqueId, '1234567890');
      expect(attestation.slotNumber, 100);
      expect(attestation.blockhash, 'Bh');
      expect(attestation.payload, attestation.attestationPayload);
      final decoded = base64Decode(attestation.payload);
      expect(decoded.length, greaterThan(64));
      final json = String.fromCharCodes(decoded.sublist(64));
      expect(json, contains('"slot_number":100'));
      expect(json, contains('"blockhash":"Bh"'));
      expect(json, contains('"request_unique_id":"1234567890"'));
    });

    test('uses the default random id generator', () async {
      final attestation = await createAttestationPayload(
        (slot: 1, blockhash: 'Bh'),
        signer,
      );
      expect(attestation.requestUniqueId, hasLength(32));
      expect(
        attestation.requestUniqueId,
        matches(RegExp(r'^\d{32}$')),
      );
    });

    test('accepts longer signed messages verbatim', () async {
      final longSigner = _ReturningSigner(
        Uint8List.fromList(List.filled(72, 7)),
      );
      final attestation = await createAttestationPayload(
        (slot: 1, blockhash: 'Bh'),
        longSigner,
        requestIdGenerator: () => '42',
      );
      final decoded = base64Decode(attestation.payload);
      expect(decoded, hasLength(72));
    });

    test('rejects short signatures', () async {
      final shortSigner = _ReturningSigner(
        Uint8List.fromList(List.filled(8, 1)),
      );
      await expectLater(
        createAttestationPayload(
          (slot: 1, blockhash: 'Bh'),
          shortSigner,
          requestIdGenerator: () => '42',
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Invalid signature length: expected 64, got 8'),
          ),
        ),
      );
    });
  });

  group('createAttestationPayloadFromClient', () {
    test('fetches block data from the client', () async {
      var calls = 0;
      final attestation = await createAttestationPayloadFromClient(
        () async {
          calls++;
          return (slot: 7, blockhash: 'Bh');
        },
        signer,
        requestIdGenerator: () => '999',
      );
      expect(calls, 1);
      expect(attestation.requestUniqueId, '999');
    });
  });

  group('createRequestUniqueId', () {
    test('generates 32 digits', () {
      final id = createRequestUniqueId();
      expect(id, hasLength(32));
      expect(id, matches(RegExp(r'^\d+$')));
    });
  });

  group('resolveFundingPreflightRpcUrl', () {
    test('prefers the explicit RPC URL', () {
      expect(
        resolveFundingPreflightRpcUrl(localDev: true, rpcUrl: ' https://rpc '),
        'https://rpc',
      );
    });

    test('returns null in local development', () {
      expect(
        resolveFundingPreflightRpcUrl(localDev: true),
        isNull,
      );
    });

    test('defaults to mainnet', () {
      expect(
        resolveFundingPreflightRpcUrl(localDev: false),
        defaultMainnetRpcUrl,
      );
    });
  });

  group('formatSolAmount', () {
    test('formats lamports as SOL', () {
      expect(formatSolAmount(16000000), '0.016000');
      expect(formatSolAmount(0), '0.000000');
    });
  });

  group('ensurePublicationSignerBalance', () {
    test('passes for a funded signer', () async {
      final warning = await ensurePublicationSignerBalance(
        publicKey: '11111111111111111111111111111111',
        localDev: false,
        fetchBalance: (_, _) async => 20000000,
      );
      expect(warning, isNull);
    });

    test('throws for an unfunded signer', () async {
      await expectLater(
        ensurePublicationSignerBalance(
          publicKey: '11111111111111111111111111111111',
          localDev: false,
          fetchBalance: (_, _) async => 100,
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('has 0.000000 SOL, but publishing needs at least'),
          ),
        ),
      );
    });

    test('warns when the RPC fails', () async {
      final warning = await ensurePublicationSignerBalance(
        publicKey: '11111111111111111111111111111111',
        localDev: false,
        fetchBalance: (_, _) async => throw Exception('rpc down'),
      );
      expect(warning, contains('Unable to confirm the signer balance'));
      expect(warning, contains('rpc down'));
    });

    test('throws for an invalid public key', () async {
      await expectLater(
        ensurePublicationSignerBalance(
          publicKey: 'not-a-valid-address',
          localDev: false,
          fetchBalance: (_, _) async => 0,
        ),
        throwsA(
          isA<PublisherCliException>().having(
            (error) => error.message,
            'message',
            contains('Invalid signer public key for balance preflight'),
          ),
        ),
      );
    });

    test('skips the check in local development', () async {
      var calls = 0;
      final warning = await ensurePublicationSignerBalance(
        publicKey: '11111111111111111111111111111111',
        localDev: true,
        fetchBalance: (_, _) async {
          calls++;
          return 0;
        },
      );
      expect(warning, isNull);
      expect(calls, 0);
    });

    test('propagates insufficient-balance errors distinctly', () async {
      await expectLater(
        ensurePublicationSignerBalance(
          publicKey: '11111111111111111111111111111111',
          localDev: false,
          fetchBalance: (_, _) async => throw const PublisherCliException(
            'Signer has 0.000000 SOL, but publishing needs at least '
            '0.016000 SOL available before it starts.',
          ),
        ),
        throwsA(isA<PublisherCliException>()),
      );
    });
  });
}

class _ReturningSigner implements PublicationSigner {
  _ReturningSigner(this.signature);

  final Uint8List signature;

  @override
  String get address => 'Address1111111111111111111111111111111111111';

  @override
  Future<Uint8List> signMessage(Uint8List message) async => signature;

  @override
  Future<Transaction> signTransaction(Transaction transaction) async =>
      throw UnimplementedError();
}
