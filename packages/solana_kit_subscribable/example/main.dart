// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

void main() {
  final publisher = createDataPublisher();

  final unsubscribe = publisher.on('slot', (data) {
    print('Received slot update: $data');
  });

  publisher
    ..publish('slot', 100)
    ..publish('slot', 101);

  unsubscribe();
  publisher.publish('slot', 102);
}
