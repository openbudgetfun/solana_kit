// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print
import 'package:solana_kit_errors/solana_kit_errors.dart';

void main() {
  final context = <String, Object?>{
    'instruction': 'transfer',
    'amount': 42,
    'authority': 'demo-wallet',
  };

  final encoded = encodeContextObject(context);
  final decoded = decodeEncodedContext(encoded);

  print('Encoded context: $encoded');
  print('Decoded amount: ${decoded['amount']}');
}
