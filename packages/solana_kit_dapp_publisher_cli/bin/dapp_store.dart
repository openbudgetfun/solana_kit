import 'dart:io';

import 'package:solana_kit_dapp_publisher_cli/src/cli.dart';

/// The `dapp-store` CLI entrypoint.
///
/// ```bash
/// dapp-store --apk-file ./app.apk --whats-new "Bug fixes" --keypair ./keypair.json
/// ```
class _StdioDependencies extends DappStoreCliDependencies {
  const _StdioDependencies();
}

Future<void> main(List<String> arguments) async {
  final exitCode = await runDappStoreCli(
    arguments,
    const _StdioDependencies(),
  );
  if (exitCode != 0) {
    exit(exitCode);
  }
}
