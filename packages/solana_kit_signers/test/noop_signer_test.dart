import 'dart:typed_data';

import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:solana_kit_signers/solana_kit_signers.dart';
import 'package:solana_kit_transactions/solana_kit_transactions.dart';
import 'package:test/test.dart';

void main() {
  group('createNoopSigner', () {
    test('creates a NoopSigner from a given address', () {
      const myAddress = Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy');
      final mySigner = createNoopSigner(myAddress);

      expect(mySigner.address, equals(myAddress));
      expect(isMessagePartialSigner(mySigner), isTrue);
      expect(isTransactionPartialSigner(mySigner), isTrue);
    });

    test('returns empty signature dictionary when signing messages', () async {
      const myAddress = Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy');
      final mySigner = createNoopSigner(myAddress);

      final messages = [
        createSignableMessage('hello'),
        createSignableMessage('world'),
      ];
      final signatureDictionaries = await mySigner.signMessages(messages);

      expect(signatureDictionaries, hasLength(2));
      expect(signatureDictionaries[0], isEmpty);
      expect(signatureDictionaries[1], isEmpty);
    });

    test(
      'returns empty signature dictionary when signing transactions',
      () async {
        const myAddress = Address(
          'Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy',
        );
        final mySigner = createNoopSigner(myAddress);

        final mockTransactions = [
          Transaction(
            messageBytes: Uint8List(0),
            signatures: <Address, SignatureBytes?>{},
          ),
          Transaction(
            messageBytes: Uint8List(0),
            signatures: <Address, SignatureBytes?>{},
          ),
        ];

        final signatureDictionaries = await mySigner.signTransactions(
          mockTransactions,
        );

        expect(signatureDictionaries, hasLength(2));
        expect(signatureDictionaries[0], isEmpty);
        expect(signatureDictionaries[1], isEmpty);
      },
    );

    test('returns unmodifiable signature dictionaries', () async {
      const myAddress = Address('Gp7YgHcJciP4px5FdFnywUiMG4UcfMZV9UagSAZzDxdy');
      final mySigner = createNoopSigner(myAddress);

      final messages = [createSignableMessage('hello')];
      final signatureDictionaries = await mySigner.signMessages(messages);

      expect(
        () => signatureDictionaries[0][const Address('test')] = SignatureBytes(
          Uint8List(64),
        ),
        throwsUnsupportedError,
      );
    });
  });
}
