import 'dart:convert';

import 'package:solana_kit_rpc_spec_types/solana_kit_rpc_spec_types.dart';
import 'package:test/test.dart';

void main() {
  group('InboundPayloadLimits', () {
    test(
      'budget diagnostics identify the limit without including payloads',
      () {
        const payload = 'sensitive wallet response';

        expect(
          () => const InboundPayloadLimits(maxBytes: 8).checkText(payload),
          throwsA(
            isA<InboundPayloadLimitException>().having(
              (error) => error.toString(),
              'diagnostic',
              allOf(contains('bytes'), contains('8'), isNot(contains(payload))),
            ),
          ),
        );
      },
    );

    for (final text in ['ascii', 'é', '😀', '\ud800', '\udc00', 'é😀ascii']) {
      test('counts UTF-8 bytes for ${jsonEncode(text)}', () {
        final bytes = utf8.encode(text).length;
        final exact = InboundPayloadLimits(maxBytes: bytes);
        expect(exact.checkText(text), bytes);
        expect(
          () => InboundPayloadLimits(maxBytes: bytes - 1).checkText(text),
          throwsA(isA<InboundPayloadLimitException>()),
        );
      });
    }

    test('ignores delimiters and escapes inside JSON strings', () {
      final text = jsonEncode({'value': r'[[[{{{\"[[['});
      expect(
        () => const InboundPayloadLimits(maxJsonDepth: 1).checkText(text),
        returnsNormally,
      );
    });

    test('accepts exact depth and token budgets', () {
      const limits = InboundPayloadLimits(maxJsonDepth: 2, maxJsonTokens: 4);
      expect(() => limits.checkText('{"x":[true]}'), returnsNormally);
      expect(
        () => limits.checkText('{"x":[[true]]}'),
        throwsA(isA<InboundPayloadLimitException>()),
      );
      expect(
        () => limits.checkText('{"x":[true,null]}'),
        throwsA(isA<InboundPayloadLimitException>()),
      );
    });

    for (final limits in [
      const InboundPayloadLimits(maxBytes: 0),
      const InboundPayloadLimits(maxJsonDepth: -1),
      const InboundPayloadLimits(maxJsonTokens: 0),
    ]) {
      test('rejects non-positive configuration $limits', () {
        expect(limits.validate, throwsArgumentError);
      });
    }
  });
}
