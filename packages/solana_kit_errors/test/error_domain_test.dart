import 'package:solana_kit_errors/solana_kit_errors.dart';
import 'package:test/test.dart';

void main() {
  group('getSolanaErrorDomain', () {
    test('classifies JSON-RPC codes', () {
      expect(
        getSolanaErrorDomain(SolanaErrorCode.jsonRpcInternalError),
        SolanaErrorDomain.jsonRpc,
      );
    });

    test('classifies transaction codes', () {
      expect(
        getSolanaErrorDomain(SolanaErrorCode.transactionSignaturesMissing),
        SolanaErrorDomain.transaction,
      );
    });

    test('classifies codecs codes', () {
      expect(
        getSolanaErrorDomain(SolanaErrorCode.codecsUnionVariantOutOfRange),
        SolanaErrorDomain.codecs,
      );
    });

    // Note: SolanaErrorDomain.unknown is only reachable via getSolanaErrorDomain
    // for enum values whose numeric value falls outside all known ranges.
    // All current enum members map to a known domain.
  });

  group('domain helpers', () {
    test('classifies SolanaError instances by domain', () {
      final error = SolanaError(SolanaErrorCode.rpcTransportHttpError, {
        'statusCode': 500,
      });

      expect(error.domain, SolanaErrorDomain.rpc);
      expect(error.isInDomain(SolanaErrorDomain.rpc), isTrue);
      expect(isSolanaErrorInDomain(error, SolanaErrorDomain.rpc), isTrue);
      expect(
        isSolanaErrorInDomain(error, SolanaErrorDomain.transaction),
        isFalse,
      );
    });

    test('classifies raw code extension helpers', () {
      expect(
        SolanaErrorCode.heliusRpcError.solanaErrorDomain,
        SolanaErrorDomain.helius,
      );
      expect(
        SolanaErrorCode.heliusRpcError.isSolanaErrorDomain(
          SolanaErrorDomain.helius,
        ),
        isTrue,
      );
    });
  });
}
