import 'package:solana_kit_keys/solana_kit_keys.dart';

import '../setup.dart';

/// Exports a test key in a child process with an independently controlled PATH.
Future<void> main(List<String> arguments) async {
  final keyPair = createKeyPairFromBytes(mockKeyBytes);

  try {
    await writeKeyPair(keyPair, arguments.single);
  } finally {
    keyPair.dispose();
  }
}
