import 'package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('getBaseXResliceCodec', () {
    final base8 = getBaseXResliceCodec('01234567', 3);

    test('can encode strings by reslicing bits', () {
      // 8 times 3 bits gives us 3 bytes.
      expect(base8.encode('77777777'), equals(b('ffffff')));
      expect(base8.read(b('ffffff'), 0), equals(('77777777', 3)));
      expect(base8.read(b('00ffffff'), 1), equals(('77777777', 4)));

      // Empty byte array.
      expect(base8.encode(''), equals(b('')));
      expect(base8.read(b(''), 0), equals(('', 0)));
      expect(base8.read(b('ff'), 1), equals(('', 1)));

      // Single byte little-endian.
      expect(base8.encode('000'), equals(b('00')));
      expect(base8.decode(b('00')), equals('000'));
      expect(base8.encode('100'), equals(b('20')));
      expect(base8.decode(b('20')), equals('100'));
      expect(base8.encode('200'), equals(b('40')));
      expect(base8.decode(b('40')), equals('200'));
      expect(base8.encode('300'), equals(b('60')));
      expect(base8.decode(b('60')), equals('300'));
      expect(base8.encode('400'), equals(b('80')));
      expect(base8.decode(b('80')), equals('400'));
      expect(base8.encode('500'), equals(b('a0')));
      expect(base8.decode(b('a0')), equals('500'));
      expect(base8.encode('600'), equals(b('c0')));
      expect(base8.decode(b('c0')), equals('600'));
      expect(base8.encode('700'), equals(b('e0')));
      expect(base8.decode(b('e0')), equals('700'));

      // Single byte big-endian.
      expect(base8.encode('000'), equals(b('00')));
      expect(base8.decode(b('00')), equals('000'));
      expect(base8.encode('002'), equals(b('01')));
      expect(base8.decode(b('01')), equals('002'));
      expect(base8.encode('004'), equals(b('02')));
      expect(base8.decode(b('02')), equals('004'));
      expect(base8.encode('006'), equals(b('03')));
      expect(base8.decode(b('03')), equals('006'));
      expect(base8.encode('010'), equals(b('04')));
      expect(base8.decode(b('04')), equals('010'));
      expect(base8.encode('012'), equals(b('05')));
      expect(base8.decode(b('05')), equals('012'));
      expect(base8.encode('014'), equals(b('06')));
      expect(base8.decode(b('06')), equals('014'));
      expect(base8.encode('016'), equals(b('07')));
      expect(base8.decode(b('07')), equals('016'));
    });
  });
}
