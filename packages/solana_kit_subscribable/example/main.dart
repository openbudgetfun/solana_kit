// Examples intentionally print CLI output for demonstration purposes.
// ignore_for_file: avoid_print

import 'package:solana_kit_subscribable/solana_kit_subscribable.dart';

void main() {
  final channels = ChannelStreamController();

  final subscription = channels.stream<int>('slot').listen((data) {
    print('Received slot update: $data');
  });

  channels
    ..add('slot', 100)
    ..add('slot', 101);

  subscription.cancel();
  channels
    ..add('slot', 102)
    ..close();
}
