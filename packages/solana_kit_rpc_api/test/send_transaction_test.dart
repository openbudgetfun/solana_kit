import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_rpc_api/solana_kit_rpc_api.dart';
import 'package:solana_kit_rpc_types/solana_kit_rpc_types.dart';
import 'package:test/test.dart';

void main() {
  group('SendTransactionConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = SendTransactionConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes encoding when set', () {
      const config = SendTransactionConfig(encoding: 'base64');
      final json = config.toJson();
      expect(json['encoding'], 'base64');
    });

    test('toJson includes maxRetries when set', () {
      final config = SendTransactionConfig(maxRetries: BigInt.from(5));
      final json = config.toJson();
      expect(json['maxRetries'], BigInt.from(5));
    });

    test('toJson includes minContextSlot when set', () {
      final config = SendTransactionConfig(minContextSlot: BigInt.from(1000));
      final json = config.toJson();
      expect(json['minContextSlot'], BigInt.from(1000));
    });

    test('toJson includes preflightCommitment when set', () {
      const config = SendTransactionConfig(
        preflightCommitment: Commitment.confirmed,
      );
      final json = config.toJson();
      expect(json['preflightCommitment'], 'confirmed');
    });

    test('toJson includes skipPreflight when set', () {
      const config = SendTransactionConfig(skipPreflight: true);
      final json = config.toJson();
      expect(json['skipPreflight'], true);
    });

    test('toJson includes all fields when all set', () {
      final config = SendTransactionConfig(
        encoding: 'base64',
        maxRetries: BigInt.from(3),
        minContextSlot: BigInt.from(500),
        preflightCommitment: Commitment.finalized,
        skipPreflight: false,
      );
      final json = config.toJson();
      expect(json, hasLength(5));
      expect(json['encoding'], 'base64');
      expect(json['maxRetries'], BigInt.from(3));
      expect(json['minContextSlot'], BigInt.from(500));
      expect(json['preflightCommitment'], 'finalized');
      expect(json['skipPreflight'], false);
    });
  });

  group('sendTransactionParams', () {
    test('returns list with only transaction when no config', () {
      final params = sendTransactionParams('base64EncodedTx==');
      expect(params, hasLength(1));
      expect(params[0], 'base64EncodedTx==');
    });

    test('returns list with transaction and config when config provided', () {
      final params = sendTransactionParams(
        'base64EncodedTx==',
        const SendTransactionConfig(skipPreflight: true),
      );
      expect(params, hasLength(2));
      expect(params[0], 'base64EncodedTx==');
      expect(params[1], isA<Map<String, Object?>>());
      final config = params[1]! as Map<String, Object?>;
      expect(config['skipPreflight'], true);
    });
  });

  group('SimulateTransactionConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = SimulateTransactionConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes accounts config when set', () {
      const config = SimulateTransactionConfig(
        accounts: SimulateTransactionAccountsConfig(
          addresses: [Address('11111111111111111111111111111111')],
          encoding: 'base64',
        ),
      );
      final json = config.toJson();
      expect(json['accounts'], isA<Map<String, Object?>>());
      final accounts = json['accounts']! as Map<String, Object?>;
      expect(accounts['addresses'], ['11111111111111111111111111111111']);
      expect(accounts['encoding'], 'base64');
    });

    test('toJson includes all fields when all set', () {
      final config = SimulateTransactionConfig(
        accounts: const SimulateTransactionAccountsConfig(
          addresses: [Address('11111111111111111111111111111111')],
        ),
        commitment: Commitment.confirmed,
        encoding: 'base64',
        innerInstructions: true,
        minContextSlot: BigInt.from(100),
        replaceRecentBlockhash: true,
      );
      final json = config.toJson();
      expect(json, hasLength(6));
      expect(json['accounts'], isNotNull);
      expect(json['commitment'], 'confirmed');
      expect(json['encoding'], 'base64');
      expect(json['innerInstructions'], true);
      expect(json['minContextSlot'], BigInt.from(100));
      expect(json['replaceRecentBlockhash'], true);
    });
  });

  group('simulateTransactionParams', () {
    test('returns list with only transaction when no config', () {
      final params = simulateTransactionParams('encodedTx==');
      expect(params, hasLength(1));
      expect(params[0], 'encodedTx==');
    });

    test('returns list with transaction and config when config provided', () {
      final params = simulateTransactionParams(
        'encodedTx==',
        const SimulateTransactionConfig(sigVerify: true),
      );
      expect(params, hasLength(2));
      expect(params[0], 'encodedTx==');
      expect(params[1], isA<Map<String, Object?>>());
    });
  });

  group('RequestAirdropConfig', () {
    test('toJson returns empty map when no options set', () {
      const config = RequestAirdropConfig();
      expect(config.toJson(), isEmpty);
    });

    test('toJson includes commitment when set', () {
      const config = RequestAirdropConfig(commitment: Commitment.finalized);
      final json = config.toJson();
      expect(json['commitment'], 'finalized');
    });
  });

  group('requestAirdropParams', () {
    test('returns list with address and lamports when no config', () {
      final params = requestAirdropParams(
        const Address('11111111111111111111111111111111'),
        Lamports(BigInt.from(1000000000)),
      );
      expect(params, hasLength(2));
      expect(params[0], '11111111111111111111111111111111');
      expect(params[1], BigInt.from(1000000000));
    });

    test('returns list with address, lamports, and config', () {
      final params = requestAirdropParams(
        const Address('11111111111111111111111111111111'),
        Lamports(BigInt.from(1000000000)),
        const RequestAirdropConfig(commitment: Commitment.confirmed),
      );
      expect(params, hasLength(3));
      expect(params[0], '11111111111111111111111111111111');
      expect(params[1], BigInt.from(1000000000));
      expect(params[2], isA<Map<String, Object?>>());
    });
  });
}
