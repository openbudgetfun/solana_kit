import 'dart:convert';
import 'dart:io';

/// Guards the `versions.json` inventory that mdt renders into every package
/// README's installation section.
///
/// The release tooling updates the versions of keys that already exist but
/// does not add keys for newly published packages, so the file drifts silently
/// over time: READMEs tell consumers to depend on a bare `^` with no version,
/// deleted packages keep stale entries, and private apps keep stale versions.
/// `mdt check` cannot catch this because the provider render and the consumer
/// agree on the same broken data.
///
/// This check compares `versions.json` with the workspace manifests in both
/// directions:
///
/// - every publishable package under `packages/` (plus the npm renderer and
///   the docs site) must have an entry matching its manifest version, and
/// - every entry other than the `@solana/kit` upstream marker must correspond
///   to a package that still exists.
///
/// Run through `docs:check`.
const _upstreamMarkerKey = '@solana/kit';

void main() {
  final versions = _readVersions();
  final errors = <String>[];

  for (final package in _manifests()) {
    final entry = versions[package.name];

    if (entry == null) {
      if (package.publishable) {
        errors.add(
          '${package.source}: `${package.name}` has no `versions.json` entry, '
          'so its README installation section renders without a version.',
        );
      }

      continue;
    }

    if (entry != package.version) {
      errors.add(
        '${package.source}: `${package.name}` is `${package.version}` in its '
        'manifest but `$entry` in `versions.json`.',
      );
    }
  }

  final knownPackages = _manifests().map((package) => package.name).toSet();
  const allowedNonPackageKeys = {_upstreamMarkerKey, 'solana_kit_docs_site'};

  for (final key in versions.keys) {
    if (knownPackages.contains(key) || allowedNonPackageKeys.contains(key)) {
      continue;
    }

    errors.add(
      'versions.json: `$key` does not match any package in the workspace; '
      'remove the stale entry.',
    );
  }

  if (errors.isNotEmpty) {
    stderr.writeln('versions.json drifted from the workspace manifests:');

    for (final error in errors) {
      stderr.writeln('  - $error');
    }

    exitCode = 1;

    return;
  }

  stdout.writeln(
    'versions.json matches the workspace manifests '
    '(${knownPackages.length} packages).',
  );
}

Map<String, String> _readVersions() {
  const path = 'versions.json';
  final file = File(path);

  if (!file.existsSync()) {
    stderr.writeln('Missing $path; run from the workspace root.');
    exit(2);
  }

  final decoded = jsonDecode(file.readAsStringSync());

  if (decoded is! Map<String, dynamic>) {
    stderr.writeln('$path is not a JSON object.');
    exit(2);
  }

  return decoded.map((key, value) => MapEntry(key, value.toString()));
}

Iterable<_Manifest> _manifests() sync* {
  // Top-level packages plus nested example apps (packages/<pkg>/example).
  final topLevel = Directory('packages').listSync().whereType<Directory>();
  final directories = <Directory>[
    ...topLevel,
    for (final package in topLevel)
      ...package.listSync().whereType<Directory>().where(
        // Directory URIs keep a trailing slash, so match any path segment.
        (child) => child.uri.pathSegments.contains('example'),
      ),
  ];

  for (final directory in directories) {
    final pubspec = File('${directory.path}/pubspec.yaml');

    if (pubspec.existsSync()) {
      yield _readPubspec(pubspec);
      continue;
    }

    final packageJson = File('${directory.path}/package.json');

    if (packageJson.existsSync()) {
      yield _readPackageJson(packageJson);
    }
  }
}

_Manifest _readPubspec(File file) {
  final lines = file.readAsLinesSync();
  final name = _matchLine(lines, RegExp(r'^name:\s*(.+)$'));
  final version = _matchLine(lines, RegExp(r'^version:\s*(.+)$'));

  if (name == null || version == null) {
    stderr.writeln('${file.path}: missing a name or version line.');
    exit(2);
  }

  return _Manifest(
    name: name,
    version: version,
    publishable: !lines.any(
      (line) => RegExp(r'''^publish_to:\s*["']?none["']?\s*$''').hasMatch(line),
    ),
    source: file.path,
  );
}

_Manifest _readPackageJson(File file) {
  final decoded = jsonDecode(file.readAsStringSync());

  if (decoded is! Map<String, dynamic>) {
    stderr.writeln('${file.path}: not a JSON object.');
    exit(2);
  }

  final name = decoded['name'];
  final version = decoded['version'];

  if (name is! String || version is! String) {
    stderr.writeln('${file.path}: missing a name or version field.');
    exit(2);
  }

  return _Manifest(
    name: name,
    version: version,
    publishable: decoded['private'] != true,
    source: file.path,
  );
}

String? _matchLine(List<String> lines, RegExp pattern) {
  for (final line in lines) {
    final match = pattern.firstMatch(line);

    if (match == null) continue;
    var value = match.group(1)!.split('#').first.trim();

    if (value.length >= 2) {
      final quote = value[0];

      if ((quote == '"' || quote == "'") && value.endsWith(quote)) {
        value = value.substring(1, value.length - 1).trim();
      }
    }

    return value;
  }

  return null;
}

class _Manifest {
  const _Manifest({
    required this.name,
    required this.version,
    required this.publishable,
    required this.source,
  });

  final String name;
  final String version;
  final bool publishable;
  final String source;
}
