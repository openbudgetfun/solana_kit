import 'package:solana_kit/solana_kit.dart';
import 'package:test/test.dart';

void main() {
  group('createClient', () {
    test('starts with an empty map by default', () {
      final client = createClient();

      expect(client.value, isA<Map<String, Object?>>());
      expect(client.value, isEmpty);
    });

    test('wraps a typed client value', () {
      final client = createClient({'rpc': 'http://localhost'});

      expect(client.value, {'rpc': 'http://localhost'});
    });
  });

  group('SolanaKitClient.use', () {
    test('applies synchronous plugins', () async {
      final client = await createClient(
        <String, Object?>{},
      ).use((client) => extendClient(client, {'rpc': 'local'}));

      expect(client, isA<SolanaKitClient<Map<String, Object?>>>());
      expect(client.value, {'rpc': 'local'});
    });

    test('applies asynchronous plugins', () async {
      final client = await createClient(
        <String, Object?>{},
      ).use((client) async => extendClient(client, {'payer': 'generated'}));

      expect(client.value, {'payer': 'generated'});
    });

    test('chains sync and async plugins', () async {
      final withRpc = await createClient(
        <String, Object?>{},
      ).use((client) => extendClient(client, {'rpc': 'local'}));
      final withPayer = await withRpc.use(
        (client) async => extendClient(client, {'payer': 'generated'}),
      );

      expect(withPayer.value, {'rpc': 'local', 'payer': 'generated'});
    });
  });

  group('extendClient', () {
    test('adds properties and keeps the result immutable', () {
      final client = extendClient({'rpc': 'local'}, {'payer': 'generated'});

      expect(client, {'rpc': 'local', 'payer': 'generated'});
      expect(() => client['extra'] = 'nope', throwsUnsupportedError);
    });

    test('lets additions replace existing keys', () {
      final client = extendClient({'rpc': 'old'}, {'rpc': 'new'});

      expect(client, {'rpc': 'new'});
    });
  });

  group('withCleanup', () {
    test('wraps a client with cleanup logic', () {
      var disposed = false;
      final client = withCleanup({'rpc': 'local'}, () {
        disposed = true;
      });

      expect(client.value, {'rpc': 'local'});
      client.dispose();
      expect(disposed, isTrue);
    });

    test('supports asynchronous cleanup logic', () async {
      var disposed = false;
      final client = withCleanup({'rpc': 'local'}, () async {
        disposed = true;
      });

      await client.dispose();
      expect(disposed, isTrue);
    });
  });
}
