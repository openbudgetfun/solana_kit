// ignore_for_file: cascade_invocations

import 'dart:convert';
import 'dart:io';

/// Recomputes `config/package-upstream-support.json` from the release tags.
///
/// Each tagged release of a program or client package records the upstream ref
/// it was generated and verified against in `config/reference-repos.json`. This
/// script reads that config at every `"<package>/v<version>"` tag and collapses
/// consecutive releases that share an identical upstream ref into a single row,
/// so a package that shipped several patches against one upstream revision
/// reports one support row rather than one per patch.
///
/// The result is committed because CI checks out shallowly and would otherwise
/// see no tags, rendering empty tables and failing `docs:check`.
///
/// Run through `docs:update`. When git reports no tags (a shallow checkout) the
/// existing file is left untouched so a fresh clone cannot erase the history.
///
/// Usage: dart run scripts/sync_package_upstream_support.dart [--check|--write]
void main(List<String> args) {
  final mode = args.isEmpty ? '--check' : args.single;
  if (mode != '--check' && mode != '--write') {
    stderr.writeln(
      'Usage: dart run scripts/sync_package_upstream_support.dart '
      '[--check|--write]',
    );
    exitCode = 2;
    return;
  }

  const configPath = 'config/reference-repos.json';
  const outputPath = 'config/package-upstream-support.json';

  final tags = _gitLines(['tag', '-l']);
  if (tags.isEmpty) {
    stdout.writeln(
      'No git tags available; leaving $outputPath unchanged. '
      'Run in a full clone to refresh the support history.',
    );
    return;
  }

  final config =
      jsonDecode(File(configPath).readAsStringSync()) as Map<String, Object?>;
  final packageRepos = _packageRepos(config);
  final releasesByPackage = _releaseTags(tags);
  final groupReleases = _groupReleases('config/upstream-versions.json');

  final packages = <String, Object?>{};
  for (final entry in packageRepos.entries) {
    final package = entry.key;
    // The `solana_kit` ↔ `@solana/kit` parity table serves this package
    // already, so it does not need a second generated table.
    if (package == 'solana_kit') continue;

    var runs = _supportRuns(
      package: package,
      repos: entry.value,
      versions: releasesByPackage[package] ?? const [],
    );
    var versionAxis = 'package';
    if (runs.isEmpty) {
      // Lockstep group members have no `"<package>/v…"` tags of their own;
      // their history lives in `upstream-versions.json` repoPins, keyed by the
      // umbrella `solana_kit` release.
      runs = _groupSupportRuns(repos: entry.value, group: groupReleases);
      versionAxis = 'solana_kit';
    }
    if (runs.isEmpty) continue;
    packages[package] = {
      'repos': entry.value,
      'versionAxis': versionAxis,
      'runs': runs,
    };
  }

  final encoded =
      '${const JsonEncoder.withIndent('  ').convert({
        'comment': 'Upstream support history per package. Generated from '
            'config/reference-repos.json at each release tag by '
            'scripts/sync_package_upstream_support.dart; consecutive releases that '
            'share an upstream ref are collapsed into one `from`–`to` range. Run '
            '`docs:update` to refresh. Do not edit by hand.',
        'packages': packages,
      })}\n';

  final output = File(outputPath);
  final previous = output.existsSync() ? output.readAsStringSync() : null;
  if (previous == encoded) {
    stdout.writeln('$outputPath is up to date.');
    return;
  }

  if (mode == '--write') {
    output.writeAsStringSync(encoded);
    stdout.writeln('Updated $outputPath.');
    return;
  }

  stderr.writeln('$outputPath is stale.');
  stderr.writeln(
    'Run `dart run scripts/sync_package_upstream_support.dart --write`.',
  );
  exitCode = 1;
}

/// Maps each Dart package to the upstream repository names it ports.
Map<String, List<String>> _packageRepos(Map<String, Object?> config) {
  final result = <String, List<String>>{};
  for (final repo
      in (config['repos'] as List<Object?>? ?? const [])
          .cast<Map<String, Object?>>()) {
    final name = repo['name'] as String?;
    if (name == null) continue;
    final packages = switch (repo['packages']) {
      final List<Object?> list => list.cast<String>(),
      _ => <String>[if (repo['package'] != null) '${repo['package']}'],
    };
    for (final package in packages) {
      (result[package] ??= <String>[]).add(name);
    }
  }
  for (final repos in result.values) {
    repos.sort();
  }
  return Map.fromEntries(
    result.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
}

/// Groups the `"<package>/v<version>"` tags by package, newest last.
Map<String, List<String>> _releaseTags(List<String> tags) {
  final pattern = RegExp(r'^([A-Za-z0-9_]+)/v(\d+\.\d+\.\d+)$');
  final result = <String, List<String>>{};
  for (final tag in tags) {
    final match = pattern.firstMatch(tag);
    if (match == null) continue;
    (result[match.group(1)!] ??= <String>[]).add(match.group(2)!);
  }
  for (final versions in result.values) {
    versions.sort(_compareVersions);
  }
  return result;
}

/// The `repoPins` rows from `config/upstream-versions.json`, newest first, read
/// as `(solanaKit version, released-ish label, pins)`.
List<({String version, Map<String, String> pins})> _groupReleases(String path) {
  final file = File(path);
  if (!file.existsSync()) return const [];
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, Object?>) return const [];
  final rows = (decoded['repoPins'] as List<Object?>? ?? const [])
      .cast<Map<String, Object?>>();
  return [
    for (final row in rows)
      (
        version: '${row['solanaKit']}',
        pins: {
          for (final entry
              in (row['pins'] as Map<String, Object?>? ?? const {}).entries)
            entry.key: '${entry.value}',
        },
      ),
  ];
}

/// Builds support runs for a package that has no release tags of its own,
/// using the umbrella `solana_kit` release history.
List<Map<String, Object?>> _groupSupportRuns({
  required List<String> repos,
  required List<({String version, Map<String, String> pins})> group,
}) {
  final runs = <Map<String, Object?>>[];
  // `group` is newest first; collapse oldest first so the `from`-`to` range
  // reads in ascending order.
  for (final release in group.reversed) {
    final pins = <String, String>{
      for (final repo in repos)
        if (release.pins[repo] != null) repo: release.pins[repo]!,
    };
    if (pins.isEmpty) continue;
    final last = runs.isEmpty ? null : runs.last;
    if (last != null && _samePins(last['pins'], pins)) {
      last['to'] = release.version;
      continue;
    }
    runs.add({
      'from': release.version,
      'to': release.version,
      'released': '',
      'releasedTo': '',
      'pins': pins,
    });
  }
  return runs.reversed.toList();
}

/// Builds the collapsed support runs for one package.
List<Map<String, Object?>> _supportRuns({
  required String package,
  required List<String> repos,
  required List<String> versions,
}) {
  final runs = <Map<String, Object?>>[];
  for (final version in versions) {
    final tag = '$package/v$version';
    final raw = _git(['show', '$tag:config/reference-repos.json']);
    if (raw == null) continue;
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      continue;
    }
    if (decoded is! Map<String, Object?>) continue;

    final pins = <String, String>{};
    for (final repo
        in (decoded['repos'] as List<Object?>? ?? const [])
            .cast<Map<String, Object?>>()) {
      final name = repo['name'] as String?;
      if (name == null || !repos.contains(name)) continue;
      final ref = repo['ref'] as Map<String, Object?>? ?? const {};
      pins[name] = '${ref['value']}';
    }
    if (pins.isEmpty) continue;

    final released = _gitLines([
      'log',
      '-1',
      '--format=%ad',
      '--date=short',
      tag,
    ]);
    final date = released.isEmpty ? '' : released.first;

    final last = runs.isEmpty ? null : runs.last;
    if (last != null && _samePins(last['pins'], pins)) {
      last['to'] = version;
      last['releasedTo'] = date;
    } else {
      runs.add({
        'from': version,
        'to': version,
        'released': date,
        'releasedTo': date,
        'pins': pins,
      });
    }
  }
  // Newest first reads better in a table.
  return runs.reversed.toList();
}

bool _samePins(Object? left, Map<String, String> right) {
  if (left is! Map<String, Object?>) return false;
  if (left.length != right.length) return false;
  for (final entry in right.entries) {
    if (left[entry.key] != entry.value) return false;
  }
  return true;
}

int _compareVersions(String a, String b) {
  final left = a.split('.').map(int.parse).toList();
  final right = b.split('.').map(int.parse).toList();
  for (var index = 0; index < 3; index++) {
    final comparison = left[index].compareTo(right[index]);
    if (comparison != 0) return comparison;
  }
  return 0;
}

String? _git(List<String> arguments) {
  final result = Process.runSync('git', arguments);
  if (result.exitCode != 0) return null;
  return '${result.stdout}';
}

List<String> _gitLines(List<String> arguments) {
  final output = _git(arguments);
  if (output == null) return const [];
  return output
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
}
