import 'package:solana_kit_surfpool/solana_kit_surfpool.dart';
import 'package:test/test.dart';

void main() {
  group('SurfpoolException', () {
    test('formats messages with and without causes', () {
      expect(
        const SurfpoolException('failed').toString(),
        'SurfpoolException: failed',
      );
      expect(
        const SurfpoolException('failed', cause: 'cause').toString(),
        'SurfpoolException: failed (cause)',
      );
    });
  });

  group('SurfpoolRpcException', () {
    test('formats transport and RPC context', () {
      expect(
        const SurfpoolRpcException(
          'failed',
          method: 'surfnet_setAccount',
          statusCode: 500,
          rpcCode: -32000,
          cause: 'payload',
        ).toString(),
        'SurfpoolRpcException: failed, method: surfnet_setAccount, '
        'statusCode: 500, rpcCode: -32000, cause: payload',
      );
    });
  });

  group('SurfnetProcessException', () {
    test('uses base Surfpool exception formatting', () {
      expect(
        const SurfnetProcessException('missing binary').toString(),
        'SurfpoolException: missing binary',
      );
    });
  });
}
