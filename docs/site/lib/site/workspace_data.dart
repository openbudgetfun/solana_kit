/// Facts the site reads from the rest of the workspace at build time.
///
/// The landing page quotes real, CI-checked code from `examples/` and real
/// version numbers from `versions.json`, so it cannot drift from what ships.
/// Anything missing throws: a build that silently showed a stale version or
/// an empty snippet would be worse than one that fails.
library;

import 'dart:convert';
import 'dart:io';

/// The workspace facts the site renders.
final class WorkspaceData {
  /// Creates workspace data from already-loaded values.
  const WorkspaceData({
    required this.upstreamKitVersion,
    required this.umbrellaVersion,
    required this.packageCount,
    required this.examplesDirectory,
  });

  /// Loads the data from the workspace containing [start], which defaults
  /// to the current directory.
  factory WorkspaceData.load([Directory? start]) {
    final root = findWorkspaceRoot(start ?? Directory.current);
    final versions = jsonDecode(
      File('${root.path}/versions.json').readAsStringSync(),
    );

    if (versions is! Map<String, Object?>) {
      throw const FormatException('versions.json must be a JSON object.');
    }

    String version(String key) => switch (versions[key]) {
      final String value when value.isNotEmpty => value,
      _ => throw FormatException('versions.json has no "$key" version.'),
    };

    return WorkspaceData(
      upstreamKitVersion: version('@solana/kit'),
      umbrellaVersion: version('solana_kit'),
      packageCount: _publishedPackageCount(Directory('${root.path}/packages')),
      examplesDirectory: Directory('${root.path}/examples'),
    );
  }

  /// The `@solana/kit` release the port tracks, such as `8.6.0`.
  final String upstreamKitVersion;

  /// The current `solana_kit` umbrella package version.
  final String umbrellaVersion;

  /// How many packages under `packages/` are published to pub.dev.
  final int packageCount;

  /// The runnable examples that the landing page quotes.
  final Directory examplesDirectory;

  /// Returns the code between `// #docregion <region>` and
  /// `// #enddocregion <region>` in the example [file], dedented.
  ///
  /// A region may appear several times in one file; the pieces are joined
  /// with a blank line, so a snippet can skip the parts of an example that
  /// only print output.
  String exampleRegion(String file, String region) {
    final source = File('${examplesDirectory.path}/$file');

    if (!source.existsSync()) {
      throw StateError('Example $file does not exist in examples/.');
    }

    return extractRegion(source.readAsStringSync(), region, label: file);
  }
}

final _unpublished = RegExp(r'^publish_to:\s*none\s*$', multiLine: true);

int _publishedPackageCount(Directory packages) {
  final count = packages
      .listSync()
      .whereType<Directory>()
      .map((package) => File('${package.path}/pubspec.yaml'))
      .where((pubspec) => pubspec.existsSync())
      .where((pubspec) => !_unpublished.hasMatch(pubspec.readAsStringSync()))
      .length;

  if (count == 0) {
    throw StateError('No published packages found in ${packages.path}.');
  }

  return count;
}

/// Walks up from [start] to the directory holding `versions.json` and
/// `examples/`.
Directory findWorkspaceRoot(Directory start) {
  var current = start.absolute;

  while (true) {
    if (File('${current.path}/versions.json').existsSync() &&
        Directory('${current.path}/examples').existsSync()) {
      return current;
    }

    final parent = current.parent;

    if (parent.path == current.path) {
      throw StateError(
        'Could not find the workspace root above ${start.absolute.path}.',
      );
    }

    current = parent;
  }
}

final _regionMarker = RegExp(r'^\s*//\s*#(end)?docregion\s+([\w-]+)\s*$');

/// Extracts the named [region] from [source]; see
/// [WorkspaceData.exampleRegion].
String extractRegion(String source, String region, {String label = 'source'}) {
  final pieces = <List<String>>[];
  List<String>? current;

  for (final line in const LineSplitter().convert(source)) {
    final marker = _regionMarker.firstMatch(line);

    if (marker != null) {
      if (marker[2] != region) continue;

      if (marker[1] == null) {
        if (current != null) {
          throw FormatException('$label opens region "$region" twice.');
        }
        current = [];
      } else {
        if (current == null) {
          throw FormatException('$label closes region "$region" unopened.');
        }
        pieces.add(current);
        current = null;
      }

      continue;
    }

    current?.add(line);
  }

  if (current != null) {
    throw FormatException('$label never closes region "$region".');
  }

  if (pieces.isEmpty || pieces.every((piece) => piece.isEmpty)) {
    throw StateError('$label has no "$region" region.');
  }

  return pieces.map(_dedent).join('\n\n');
}

String _dedent(List<String> lines) {
  final indents = lines
      .where((line) => line.trim().isNotEmpty)
      .map((line) => line.length - line.trimLeft().length);
  final indent = indents.isEmpty ? 0 : indents.reduce((a, b) => a < b ? a : b);

  return lines
      .map((line) => line.length >= indent ? line.substring(indent) : '')
      .join('\n')
      .trimRight();
}
