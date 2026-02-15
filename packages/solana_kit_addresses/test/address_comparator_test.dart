import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:test/test.dart';

void main() {
  group('getAddressComparator', () {
    test('sorts base 58 addresses correctly', () {
      // These addresses were chosen such that sorting these conventionally
      // (ie. using the default `String.compareTo`) or numerically would fail
      // to produce the expected output. This exercises the 'specialness' of
      // the base 58 encoded address comparator.
      final addresses = [
        const Address('Ht1VrhoyhwMGMpBBi89BPdJp5R39Mu49suKx3A22W9Qs'),
        const Address('J9ZSLc9qPg3FR8UqfN6ae1QkVReUmnpLgQqFkGEPqmod'),
        const Address('6JYSQqSHY1E5JDwEfgWMieozqA1KCwiP2cH69to9eWKH'),
        const Address('7YR1xA7yzFAT4yQCsS4rpowjU1tsh5YUJd9hWMHRppcX'),
        const Address('7grJ9YUAEHxckLFqCY7fq8cM1UrragNSuPH1dvwJ8EEK'),
        const Address('AJBPNWCjVLwxff2eJynW56cMRCGmyU4y3vbuvtVdgVgb'),
        const Address('B8A2zUEDtJjR7nrokNUJYhgUQiwEBzC88rZc6WUE5ZeF'),
        const Address('BKggsVVp7yLmXtPuBDtC3FXBzvLyyye3Q2tFKUUGCHLj'),
        const Address('Ds72joawSKQ9nCDAAmGMKFiwiY6HR7PDzYDHDzZom3tj'),
        const Address('F1zKr4ZUYo5UAnH1fvYaD6R7ne137NYfS1r5HrCb8NpF'),
      ]..sort(getAddressComparator());

      expect(
        addresses.map((a) => a.value).toList(),
        equals([
          '6JYSQqSHY1E5JDwEfgWMieozqA1KCwiP2cH69to9eWKH',
          '7grJ9YUAEHxckLFqCY7fq8cM1UrragNSuPH1dvwJ8EEK',
          '7YR1xA7yzFAT4yQCsS4rpowjU1tsh5YUJd9hWMHRppcX',
          'AJBPNWCjVLwxff2eJynW56cMRCGmyU4y3vbuvtVdgVgb',
          'B8A2zUEDtJjR7nrokNUJYhgUQiwEBzC88rZc6WUE5ZeF',
          'BKggsVVp7yLmXtPuBDtC3FXBzvLyyye3Q2tFKUUGCHLj',
          'Ds72joawSKQ9nCDAAmGMKFiwiY6HR7PDzYDHDzZom3tj',
          'F1zKr4ZUYo5UAnH1fvYaD6R7ne137NYfS1r5HrCb8NpF',
          'Ht1VrhoyhwMGMpBBi89BPdJp5R39Mu49suKx3A22W9Qs',
          'J9ZSLc9qPg3FR8UqfN6ae1QkVReUmnpLgQqFkGEPqmod',
        ]),
      );
    });

    test('sorts identical addresses as equal', () {
      final comparator = getAddressComparator();
      const a = Address('11111111111111111111111111111111');
      expect(comparator(a, a), equals(0));
    });

    test('shorter addresses sort before longer ones with same prefix', () {
      final comparator = getAddressComparator();
      const a = Address('11111111111111111111111111111111');
      const b = Address('111111111111111111111111111111112');
      expect(comparator(a, b), lessThan(0));
    });
  });
}
