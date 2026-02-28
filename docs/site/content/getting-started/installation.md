---
title: Installation
description: Set up Solana Kit in a Dart or Flutter project.
---

Install the umbrella package:

```bash
dart pub add solana_kit
```

Then import it from your app code:

```dart
import 'package:solana_kit/solana_kit.dart';
```

## Workspace Setup

<!-- {=docsWorkspaceSetupSection} -->

```bash
# Clone the repository
git clone https://github.com/openbudgetfun/solana_kit.git
cd solana_kit

# Load devenv
direnv allow

# Install binary tools and Dart dependencies
install:all
dart pub get

# Pull reference repositories used for compatibility checks
clone:repos
```

<!-- {/docsWorkspaceSetupSection} -->

## Verify the Toolchain

Run these commands at the workspace root:

```bash
lint:all
test:all
docs:check
```

If your work requires generated docs updates, run `docs:update` before committing.
