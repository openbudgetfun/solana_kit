// ignore_for_file: cascade_invocations

import 'dart:convert';
import 'dart:io';

const _versionPattern = r'[0-9]+\.[0-9]+\.[0-9]+';

Future<void> main(List<String> args) async {
  final cloneIfMissing = args.contains('--clone-if-missing');
  final upstreamDirectory = Directory('.repos/kit');
  final upstreamPackageJson = File(
    '${upstreamDirectory.path}/packages/kit/package.json',
  );

  final trackedVersion = _extractFirstSemver(
    File('readme.md'),
    RegExp('Latest supported `@solana/kit` version: `($_versionPattern)`'),
  );
  if (trackedVersion == null) {
    stderr.writeln(
      'Failed to determine the tracked @solana/kit version from readme.md.',
    );
    exitCode = 1;
    return;
  }

  final versionFiles = [
    'readme.md',
    'packages/solana_kit/README.md',
    'docs/site/content/index.md',
    'docs/site/content/reference/upstream-compatibility.md',
  ];

  var failed = false;
  for (final path in versionFiles) {
    final file = File(path);
    final latestSupported = _extractFirstSemver(
      file,
      RegExp('Latest supported `@solana/kit` version: `($_versionPattern)`'),
    );
    final trackedBehavior = _extractFirstSemver(
      file,
      RegExp('tracks upstream APIs and behavior through `v($_versionPattern)`'),
    );

    if (latestSupported == null || trackedBehavior == null) {
      stderr.writeln('Missing upstream compatibility metadata in $path');
      failed = true;
      continue;
    }

    if (latestSupported != trackedVersion) {
      stderr.writeln(
        'Tracked version mismatch in $path: expected $trackedVersion, found $latestSupported',
      );
      failed = true;
    }

    if (trackedBehavior != trackedVersion) {
      stderr.writeln(
        'Behavior version mismatch in $path: expected $trackedVersion, found $trackedBehavior',
      );
      failed = true;
    }
  }

  if (cloneIfMissing && !upstreamDirectory.existsSync()) {
    stdout.writeln(
      'Cloning upstream @solana/kit into ${upstreamDirectory.path}',
    );
    upstreamDirectory.parent.createSync(recursive: true);
    final code = await _inherit('git', [
      'clone',
      '--depth',
      '1',
      'https://github.com/anza-xyz/kit',
      upstreamDirectory.path,
    ]);
    if (code != 0) {
      exitCode = code;
      return;
    }
  }

  if (upstreamPackageJson.existsSync()) {
    final json =
        jsonDecode(upstreamPackageJson.readAsStringSync())
            as Map<String, Object?>;
    final upstreamVersion = json['version'] as String?;
    if (upstreamVersion != null && upstreamVersion != trackedVersion) {
      stderr.writeln(
        'NOTICE: upstream @solana/kit is currently $upstreamVersion while this workspace tracks $trackedVersion.',
      );
      stderr.writeln(
        'NOTICE: update docs and parity work intentionally; do not silently bump compatibility claims.',
      );
    }
  } else {
    stderr.writeln(
      'NOTICE: skipping upstream repo drift check because ${upstreamPackageJson.path} is unavailable.',
    );
    stderr.writeln(
      'NOTICE: run clone:repos or dart run scripts/check_upstream_compatibility.dart --clone-if-missing.',
    );
  }

  if (failed) {
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'Upstream compatibility metadata is internally consistent for tracked version $trackedVersion.',
  );
}

String? _extractFirstSemver(File file, RegExp pattern) {
  final match = pattern.firstMatch(file.readAsStringSync());
  return match?.group(1);
}

Future<int> _inherit(String executable, List<String> arguments) async {
  final process = await Process.start(
    executable,
    arguments,
    mode: ProcessStartMode.inheritStdio,
  );
  return process.exitCode;
}
