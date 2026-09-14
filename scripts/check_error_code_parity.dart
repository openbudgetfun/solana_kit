// ignore_for_file: cascade_invocations

import 'dart:io';

/// Checks that this port's `SolanaErrorCode` numbers line up with the upstream
/// `@solana/kit` error codes in `.repos/kit`.
///
/// Two things are enforced:
///
/// 1. A code present in both must have the same number. Matching numbers are
///    what lets a caller compare an error across the two SDKs, and it is the
///    reason this file exists.
/// 2. A port-only code must not occupy a number upstream uses for a different
///    code. Port-only codes belong at the end of their domain's block, for
///    example `8078999` in the codec block, so upstream can keep allocating
///    inside it without a collision.
///
/// Codes upstream has that this port does not are reported as notices, not
/// failures: some are for JavaScript-only surfaces such as `@solana/react`.
void main(List<String> args) {
  final upstreamPath = args.isNotEmpty
      ? args.first
      : '.repos/kit/packages/errors/src/codes.ts';

  final upstreamFile = File(upstreamPath);
  if (!upstreamFile.existsSync()) {
    stdout.writeln(
      'NOTICE: skipping error-code parity because $upstreamPath is '
      'unavailable. Run `clone:repos` to materialize it.',
    );
    return;
  }

  final upstream = _parseUpstream(upstreamFile.readAsStringSync());
  final ours = _parsePort(
    File('packages/solana_kit_errors/lib/src/codes.dart').readAsStringSync(),
  );

  if (upstream.isEmpty || ours.isEmpty) {
    stderr.writeln('Failed to parse one of the error-code sources.');
    exitCode = 2;
    return;
  }

  final upstreamByNumber = <int, String>{};
  for (final entry in upstream.entries) {
    upstreamByNumber.putIfAbsent(entry.value.$1, () => entry.value.$2);
  }

  final mismatches = <String>[];
  final collisions = <String>[];

  for (final entry in ours.entries) {
    final number = entry.value.$1;
    final upstreamEntry = upstream[entry.key];

    if (upstreamEntry != null) {
      if (upstreamEntry.$1 != number) {
        mismatches.add(
          '${entry.value.$2}: upstream is ${upstreamEntry.$1}, '
          'this port is $number',
        );
      }
      continue;
    }

    final occupiedBy = upstreamByNumber[number];
    if (occupiedBy != null) {
      collisions.add(
        '${entry.value.$2} uses $number, which upstream uses for $occupiedBy',
      );
    }
  }

  if (mismatches.isEmpty && collisions.isEmpty) {
    final missing = upstream.keys.where((key) => !ours.containsKey(key)).length;
    stdout.writeln(
      'Error-code parity holds: ${ours.length} codes, '
      '${upstream.length} upstream, $missing upstream-only.',
    );
    return;
  }

  stderr.writeln('Error-code parity with upstream is broken:');
  for (final entry in mismatches) {
    stderr.writeln('  number differs — $entry');
  }
  for (final entry in collisions) {
    stderr.writeln('  number occupied — $entry');
  }
  stderr.writeln();
  stderr.writeln(
    'A code that exists upstream must use the upstream number. A code that '
    'does not exist upstream must move to the end of its domain block so '
    'upstream cannot collide with it. See docs/agents/error-codes.md.',
  );
  exitCode = 1;
}

/// Parses `SOLANA_ERROR__DOMAIN__NAME = number` into normalized name → number.
Map<String, (int, String)> _parseUpstream(String source) {
  final codes = <String, (int, String)>{};
  final pattern = RegExp(
    r'export const SOLANA_ERROR__([A-Z0-9_]*)__([A-Z0-9_]*)\s*=\s*(\d+);',
  );
  for (final match in pattern.allMatches(source)) {
    final name = '${match.group(1)}__${match.group(2)}';
    codes[_normalize(name)] = (int.parse(match.group(3)!), name);
  }
  return codes;
}

/// Parses the Dart enum into normalized name → (number, source name).
Map<String, (int, String)> _parsePort(String source) {
  final codes = <String, (int, String)>{};
  final pattern = RegExp(r'^\s{2}([a-zA-Z0-9_]+)\((\d+)\),', multiLine: true);
  for (final match in pattern.allMatches(source)) {
    final name = match.group(1)!;
    codes[_normalize(name)] = (int.parse(match.group(2)!), name);
  }
  return codes;
}

/// Reduces a code name to lowercase alphanumerics so the Dart camelCase name
/// and the upstream SCREAMING_SNAKE name compare equal.
String _normalize(String name) =>
    name.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
