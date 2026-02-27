import 'package:solana_kit_program_client_core/solana_kit_program_client_core.dart';
import 'package:test/test.dart';

void main() {
  group('SelfPlanAndSendFunctions', () {
    test('delegates single-item planning and sending callbacks', () async {
      final functions = SelfPlanAndSendFunctions<int, String, String>(
        planTransaction: (input) async => 'plan:$input',
        sendTransaction: (input) async => 'send:$input',
      );

      expect(await functions.planTransaction(3), 'plan:3');
      expect(await functions.sendTransaction(3), 'send:3');
    });

    test(
      'uses default batch behavior when batch callbacks are omitted',
      () async {
        final functions = SelfPlanAndSendFunctions<int, String, String>(
          planTransaction: (input) async => 'plan:$input',
          sendTransaction: (input) async => 'send:$input',
        );

        expect(await functions.planTransactions([1, 2]), ['plan:1', 'plan:2']);
        expect(await functions.sendTransactions([1, 2]), ['send:1', 'send:2']);
      },
    );

    test('uses explicit batch callbacks when provided', () async {
      final functions = SelfPlanAndSendFunctions<int, String, String>(
        planTransaction: (input) async => 'single-plan:$input',
        sendTransaction: (input) async => 'single-send:$input',
        planTransactions: (inputs) async => ['batch-plan:${inputs.length}'],
        sendTransactions: (inputs) async => ['batch-send:${inputs.length}'],
      );

      expect(await functions.planTransactions([4, 5, 6]), ['batch-plan:3']);
      expect(await functions.sendTransactions([4, 5, 6]), ['batch-send:3']);
    });
  });

  group('addSelfPlanAndSendFunctions', () {
    test('creates a configured SelfPlanAndSendFunctions wrapper', () async {
      final functions = addSelfPlanAndSendFunctions<int, String, String>(
        planTransaction: (input) async => 'plan:$input',
        sendTransaction: (input) async => 'send:$input',
      );

      expect(functions, isA<SelfPlanAndSendFunctions<int, String, String>>());
      expect(await functions.planTransaction(9), 'plan:9');
      expect(await functions.sendTransaction(9), 'send:9');
    });
  });
}
