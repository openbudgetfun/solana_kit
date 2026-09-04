/// Portal-backed CLI for publishing dApp versions to the Solana Mobile dApp
/// Store.
///
/// Install the executable with `dart pub global activate
/// solana_kit_dapp_publisher_cli`, then publish a release with:
///
/// ```bash
/// dapp-store --apk-file ./app.apk --whats-new "Bug fixes" --keypair ./keypair.json
/// ```
///
/// The API key is read from the `DAPP_STORE_API_KEY` environment variable or
/// piped through stdin.
library;

export 'package:solana_kit_dapp_publisher_cli/src/attestation.dart';
export 'package:solana_kit_dapp_publisher_cli/src/cli.dart';
export 'package:solana_kit_dapp_publisher_cli/src/errors.dart';
export 'package:solana_kit_dapp_publisher_cli/src/funding_preflight.dart';
export 'package:solana_kit_dapp_publisher_cli/src/portal_client.dart';
export 'package:solana_kit_dapp_publisher_cli/src/portal_translators.dart';
export 'package:solana_kit_dapp_publisher_cli/src/portal_types.dart';
export 'package:solana_kit_dapp_publisher_cli/src/publication_models.dart';
export 'package:solana_kit_dapp_publisher_cli/src/publication_signer.dart';
export 'package:solana_kit_dapp_publisher_cli/src/publication_workflow.dart';
export 'package:solana_kit_dapp_publisher_cli/src/release_metadata.dart';
export 'package:solana_kit_dapp_publisher_cli/src/workflow_client.dart';
