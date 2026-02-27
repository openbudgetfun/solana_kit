// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print
import 'package:solana_kit_functional/solana_kit_functional.dart';

void main() {
  final label = 'solana'
      .pipe((value) => value.toUpperCase())
      .pipe((value) => '$value KIT')
      .pipe((value) => '$value SDK');

  final score = 5
      .pipe((value) => value * 2)
      .pipe((value) => value + 7);

  print(label);
  print('Pipeline score: $score');
}
