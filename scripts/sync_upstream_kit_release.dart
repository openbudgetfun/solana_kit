// ignore_for_file: cascade_invocations

import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Keeps the tracked upstream `@solana/kit` version in step with the npm
/// registry.
///
/// The tracked version lives in `versions.json` under the `@solana/kit` key;
/// `mdt` renders it into the readme files and the docs site, and
/// `scripts/generate_upstream_docs.dart` renders the pin tables from
/// `config/reference-repos.json`. This script is the missing external half of
/// `upstream:check`: instead of verifying internal consistency, it compares
/// the tracked version against the npm dist-tags and, in `--write` mode,
/// performs the mechanical pin updates:
///
/// - `versions.json` — the `@solana/kit` compatibility marker,
/// - `config/reference-repos.json` — the `anza-xyz/kit` tag pin, its notes,
///   and the checked commit (resolved through `git ls-remote`),
/// - `docs/agents/reference-repos.md` — the documented kit pin line,
/// - `.changeset/upstream-kit-vX-Y-Z.md` — a changeset for the claim bump.
///
/// After `--write`, run `docs:update` to re-render every consumer and the
/// generated upstream tables. Behavioral parity is not this script's job:
/// `upstream:parity` in CI validates the new claim before the pin update can
/// merge.
///
/// Usage:
///
/// ```sh
/// # Report drift; exits 1 when npm and the workspace disagree.
/// dart run scripts/sync_upstream_kit_release.dart --check
///
/// # Apply the pin updates (refuses downgrades unless allowed).
/// dart run scripts/sync_upstream_kit_release.dart --write
///
/// # Compare against a different npm dist-tag, machine-readable output.
/// dart run scripts/sync_upstream_kit_release.dart --check \
///   --dist-tag canary --format json
/// ```
const _registryUrl =
    'https://registry.npmjs.org/-/package/@solana%2Fkit/dist-tags';
const _upstreamRemote = 'https://github.com/anza-xyz/kit';
const _npmPackageUrl = 'https://www.npmjs.com/package/@solana/kit';
const _trackedKey = '@solana/kit';
final _stableVersionPattern = RegExp(r'^(\d+)\.(\d+)\.(\d+)$');

Future<void> main(List<String> args) async {
  var mode = 'check';
  var distTag = 'latest';
  var allowDowngrade = false;
  var jsonOutput = false;

  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--check':
      case '--write':
        mode = args[i].substring(2);

      case '--dist-tag':
        if (++i >= args.length) _usage('missing value after --dist-tag');
        distTag = args[i];

      case '--allow-downgrade':
        allowDowngrade = true;

      case '--format':
        if (++i >= args.length) _usage('missing value after --format');

        if (args[i] != 'json') _usage("unsupported --format '${args[i]}'");
        jsonOutput = true;

      default:
        _usage("unknown argument '${args[i]}'");
    }
  }

  if (RegExp('[^A-Za-z0-9_-]').hasMatch(distTag)) {
    _usage("invalid dist-tag '$distTag'");
  }

  if (RegExp('[^A-Za-z0-9_-]').hasMatch(distTag)) {
    _usage("invalid dist-tag '$distTag'");
  }

  final tracker = _TrackedVersion.load();
  final registry = await _NpmRegistry.fetchLatest(distTag);
  final latest = registry.latest;
  final comparison = _compare(latest, tracker.version);

  switch (comparison) {
    case _VersionRelation.inSync:
      _report(
        jsonOutput,
        tracked: tracker.version,
        latest: latest,
        distTag: distTag,
        status: 'in-sync',
      );

      if (!jsonOutput) {
        stdout.writeln(
          'Tracked $_trackedKey version ${tracker.version} matches the npm '
          "'$distTag' dist-tag.",
        );
      }

    case _VersionRelation.ahead:
      if (mode == 'write') {
        await _applyPinUpdates(tracker, latest);
        _report(
          jsonOutput,
          tracked: tracker.version,
          latest: latest,
          distTag: distTag,
          status: 'updated',
        );
      } else {
        _report(
          jsonOutput,
          tracked: tracker.version,
          latest: latest,
          distTag: distTag,
          status: 'drift',
        );
        stderr.writeln(
          'npm $_npmPackageUrl publishes $latest as `$distTag`, but this '
          'workspace tracks ${tracker.version}. Update the pins with '
          '`dart run scripts/sync_upstream_kit_release.dart --write`, then run '
          '`docs:update`.',
        );
        exitCode = 1;
      }

    case _VersionRelation.behind:
      _report(
        jsonOutput,
        tracked: tracker.version,
        latest: latest,
        distTag: distTag,
        status: 'downgrade',
      );

      if (mode == 'write') {
        if (!allowDowngrade) {
          stderr.writeln(
            'npm `$distTag` is $latest, which is older than the tracked '
            '${tracker.version}. Refusing to downgrade the compatibility '
            'claim; retry with --allow-downgrade if the upstream release was '
            'retracted.',
          );
          exitCode = 1;
        } else {
          await _applyPinUpdates(tracker, latest);
        }
      } else {
        stderr.writeln(
          'Tracked ${tracker.version} is newer than npm `$distTag` ($latest); '
          'the upstream release may have been unpublished or retracted.',
        );
        exitCode = 1;
      }
  }
}

void _usage(String problem) {
  stderr.writeln('sync_upstream_kit_release: $problem');
  stderr.writeln(
    'Usage: dart run scripts/sync_upstream_kit_release.dart '
    '[--check|--write] [--dist-tag <tag>] [--allow-downgrade] [--format json]',
  );
  exitCode = 2;
}

void _report(
  bool jsonOutput, {
  required String tracked,
  required String latest,
  required String distTag,
  required String status,
}) {
  if (!jsonOutput) return;
  stdout.writeln(
    jsonEncode({
      'tracked': tracked,
      'latest': latest,
      'distTag': distTag,
      'status': status,
    }),
  );
}

/// Applies the mechanical pin updates for [latest], skipping files that
/// already carry it (so re-runs are idempotent).
Future<void> _applyPinUpdates(_TrackedVersion tracker, String latest) async {
  final tag = 'v$latest';
  final commit = _resolveTagCommit(tag);

  if (commit == null) {
    stderr.writeln(
      'Tag $tag does not exist on $_upstreamRemote yet, so the pin cannot be '
      'verified. Retry once upstream pushes the release tag.',
    );
    exitCode = 1;

    return;
  }

  tracker.write(latest);
  stdout.writeln('versions.json: $_trackedKey ${tracker.version} -> $latest');

  _ReferenceRepoPin.update(tag: tag, commit: commit);
  stdout.writeln(
    'config/reference-repos.json: kit pin -> $tag '
    '(checked commit ${commit.substring(0, 12)})',
  );

  _ReferenceRepoDocs.update(tag: tag, commitPrefix: commit.substring(0, 12));
  stdout.writeln('docs/agents/reference-repos.md: kit pin line -> $tag');
  final changeset = _Changeset.write(
    previous: tracker.version,
    latest: latest,
  );

  if (changeset == null) {
    stdout.writeln('changeset: already present for $tag');
  } else {
    stdout.writeln('changeset: wrote $changeset');
  }
}

/// Returns the commit the [tag] points at, preferring the peeled
/// (`^{}`) entry so annotated tags resolve to the commit they mark.
String? _resolveTagCommit(String tag) {
  final result = Process.runSync('git', [
    'ls-remote',
    _upstreamRemote,
    'refs/tags/$tag',
    'refs/tags/$tag^{}',
  ]);

  if (result.exitCode != 0) {
    stderr.writeln('git ls-remote failed: ${result.stderr}');

    return null;
  }

  final lines = (result.stdout as String)
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
  final peeled = lines.where((line) => line.endsWith('^{}'));
  final chosen = peeled.isNotEmpty ? peeled.last : lines.lastOrNull;

  return chosen?.split(RegExp(r'\s+')).first;
}

_VersionRelation _compare(String latest, String tracked) {
  final latestParts = _parseStable(latest);
  final trackedParts = _parseStable(tracked);

  for (var i = 0; i < 3; i++) {
    if (latestParts[i] > trackedParts[i]) return _VersionRelation.ahead;

    if (latestParts[i] < trackedParts[i]) return _VersionRelation.behind;
  }

  return _VersionRelation.inSync;
}

List<int> _parseStable(String version) {
  final match = _stableVersionPattern.firstMatch(version);

  if (match == null) {
    stderr.writeln(
      "'$version' is not a stable semver version; compatibility claims only "
      'track stable upstream releases.',
    );
    exit(2);
  }

  return [
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(
      match.group(3)!,
    ),
  ];
}

enum _VersionRelation { inSync, ahead, behind }

class _TrackedVersion {
  _TrackedVersion._(this._file, this.version);

  factory _TrackedVersion.load() {
    const path = 'versions.json';
    final file = File(path);

    if (!file.existsSync()) {
      stderr.writeln('Missing $path; run from the workspace root.');
      exit(2);
    }

    final versions =
        jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final tracked = versions[_trackedKey];

    if (tracked is! String) {
      stderr.writeln('$path has no String "$_trackedKey" entry.');
      exit(2);
    }

    return _TrackedVersion._(file, tracked);
  }

  final File _file;

  /// The tracked `@solana/kit` version before any update.
  final String version;

  void write(String latest) {
    final versions =
        jsonDecode(_file.readAsStringSync()) as Map<String, dynamic>;
    versions[_trackedKey] = latest;
    _writeJsonFile(_file, versions);
  }
}

class _ReferenceRepoPin {
  static void update({required String tag, required String commit}) {
    const path = 'config/reference-repos.json';
    final file = File(path);
    final config = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final repos = (config['repos'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    final kit = repos.singleWhere(
      (repo) => repo['name'] == 'kit',
      orElse: () {
        stderr.writeln('$path has no "kit" repository entry.');
        exit(2);
      },
    );
    final ref = kit['ref'] as Map<String, dynamic>;
    ref['value'] = tag;
    kit['notes'] = 'upstream TypeScript source from anza-xyz/kit ($tag)';
    kit['checkedCommit'] = commit;
    _writeJsonFile(file, config);
  }
}

class _ReferenceRepoDocs {
  static void update({required String tag, required String commitPrefix}) {
    const path = 'docs/agents/reference-repos.md';
    final file = File(path);
    final lines = file.readAsLinesSync();
    final tagPattern = RegExp(r'pinned to tag `v\d+\.\d+\.\d+`');
    final checkedPattern = RegExp('last checked `[0-9a-f]{7,40}`');
    var updated = false;
    var found = false;

    for (var i = 0; i < lines.length; i++) {
      if (!lines[i].contains('`.repos/kit`')) continue;
      found = true;
      var line = lines[i];
      line = line.replaceAll(tagPattern, 'pinned to tag `$tag`');

      if (checkedPattern.hasMatch(line)) {
        line = line.replaceAll(checkedPattern, 'last checked `$commitPrefix`');
      }

      if (line != lines[i]) {
        lines[i] = line;
        updated = true;
      }

      break;
    }

    if (!found) {
      stderr.writeln(
        '$path: could not find the `.repos/kit` pin line to update. Update it '
        'manually so it mentions `$tag` (docs:check validates this line).',
      );
      exitCode = 1;

      return;
    }

    // An unchanged line already carries the target pin; re-runs stay no-ops.
    if (updated) {
      file.writeAsStringSync('${lines.join('\n')}\n');
    }
  }
}

class _Changeset {
  /// Returns the path written, or null when a changeset already tracks
  /// [latest].
  static String? write({
    required String previous,
    required String latest,
  }) {
    final dashed = latest.replaceAll('.', '-');
    final path = '.changeset/upstream-kit-v$dashed.md';
    final file = File(path);

    if (file.existsSync()) return null;
    file.writeAsStringSync('''
---
"solana_kit": patch
---

# Track @solana/kit v$latest

The workspace's tracked upstream version moves from `$previous` to `$latest`. The compatibility tables, the `anza-xyz/kit` reference pin, and the rendered upstream-support sections now point at `v$latest`.

Behavioral parity for the tracked surfaces is enforced by `upstream:parity`, which runs in CI against `@solana/kit@$latest`.
''');

    return path;
  }
}

class _NpmRegistry {
  const _NpmRegistry._(this.latest);

  final String latest;

  static Future<_NpmRegistry> fetchLatest(String distTag) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30);
    try {
      final request = await client
          .getUrl(Uri.parse(_registryUrl))
          .timeout(const Duration(seconds: 30));
      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode != 200) {
        stderr.writeln(
          '$_registryUrl answered HTTP ${response.statusCode}; cannot compare '
          'the upstream version.',
        );
        exit(2);
      }

      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 30));
      final distTags = jsonDecode(body) as Map<String, dynamic>;
      final latest = distTags[distTag];

      if (latest is! String) {
        stderr.writeln(
          "npm has no '$distTag' dist-tag for $_trackedKey. Available: "
          '${distTags.keys.join(', ')}.',
        );
        exit(2);
      }

      return _NpmRegistry._(latest);

    } on TimeoutException {
      stderr.writeln('Timed out contacting the npm registry.');
      exit(2);

    } on SocketException catch (error) {
      stderr.writeln('Cannot reach the npm registry: $error');
      exit(2);

    } on FormatException catch (error) {
      stderr.writeln('The npm registry returned malformed JSON: $error');
      exit(2);
    } finally {
      client.close();
    }
  }
}

void _writeJsonFile(File file, Map<String, dynamic> json) {
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(json)}\n',
  );
}
