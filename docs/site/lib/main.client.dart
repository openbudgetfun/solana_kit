/// The entrypoint for the client environment.
library;

import 'package:jaspr/client.dart';

// This file is generated automatically by Jaspr, do not remove or edit.
import 'package:solana_kit_docs_site/main.client.options.dart';

void main() {
  Jaspr.initializeApp(options: defaultClientOptions);

  runApp(const ClientApp());
}
