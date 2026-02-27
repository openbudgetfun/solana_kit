// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print
import 'package:solana_kit_options/solana_kit_options.dart';

void main() {
  final maybeFeePayer = some('FEE_PAYER_ADDRESS');
  final noMemo = none<String>();

  final feePayerText = switch (maybeFeePayer) {
    Some<String>(:final value) => 'fee payer: $value',
    None<String>() => 'no fee payer set',
  };

  final memoText = switch (noMemo) {
    Some<String>(:final value) => 'memo: $value',
    None<String>() => 'memo not provided',
  };

  print(feePayerText);
  print(memoText);
}
