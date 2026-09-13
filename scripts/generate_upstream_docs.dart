// ignore_for_file: cascade_invocations

import 'dart:convert';
import 'dart:io';

/// Renders the upstream version tables that appear in the root readme and the
/// upstream-compatibility docs page.
///
/// The tables are generated from `config/upstream-versions.json` (the
/// historical `solana_kit` ↔ `@solana/kit` parity map) and
/// `config/reference-repos.json` (the upstream client and IDL pins the current
/// release was verified against).
///
/// Markdown tables are wrapped in a `dprint-ignore` comment so the generator
/// owns their formatting instead of the markdown formatter.
void main(List<String> args) {
  final mode = args.isEmpty ? '--check' : args.single;
  if (mode != '--check' && mode != '--write') {
    stderr.writeln(
      'Usage: dart run scripts/generate_upstream_docs.dart [--check|--write]',
    );
    exitCode = 2;
    return;
  }

  final parityData = _readJsonObject('config/upstream-versions.json');
  final parityTable = _renderParityTable(parityData);
  final repoPinTables = _renderRepoPinTables(parityData);
  final pinsTable = _renderPinsTable(
    _readJsonObject('config/reference-repos.json'),
  );

  final targets = <_Target>[
    _Target('readme.md', {'upstream-parity': parityTable}),
    _Target('docs/site/content/reference/upstream-compatibility.md', {
      'upstream-parity': parityTable,
      'upstream-repo-pins': repoPinTables,
      'upstream-pins': pinsTable,
    }),
  ];

  var drifted = false;
  final updatedPaths = <String>[];

  for (final target in targets) {
    final file = File(target.path);
    if (!file.existsSync()) {
      stderr.writeln('Missing required file: ${target.path}');
      exitCode = 2;
      return;
    }

    final original = file.readAsStringSync();
    var updated = original;
    for (final entry in target.blocks.entries) {
      updated = _replaceBlock(
        updated,
        '<!-- ${entry.key}:start -->',
        '<!-- ${entry.key}:end -->',
        entry.value,
        target.path,
      );
    }

    if (updated == original) continue;
    updatedPaths.add(target.path);
    if (mode == '--write') {
      file.writeAsStringSync(updated);
    } else {
      drifted = true;
    }
  }

  if (mode == '--write') {
    stdout.writeln(
      updatedPaths.isEmpty
          ? 'Upstream version tables are already up to date.'
          : 'Updated upstream version tables in ${updatedPaths.join(', ')}.',
    );
    return;
  }

  if (drifted) {
    stderr.writeln('Upstream version table drift detected.');
    stderr.writeln(
      'Run `dart run scripts/generate_upstream_docs.dart --write`.',
    );
    exitCode = 1;
    return;
  }

  stdout.writeln('Upstream version tables are up to date.');
}

class _Target {
  const _Target(this.path, this.blocks);

  final String path;
  final Map<String, String> blocks;
}

Map<String, Object?> _readJsonObject(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('Missing required file: $path');
    exitCode = 2;
    return const {};
  }
  if (jsonDecode(file.readAsStringSync())
      case final Map<String, Object?> json) {
    return json;
  }
  stderr.writeln('Expected a JSON object at $path');
  exitCode = 2;
  return const {};
}

String _replaceBlock(
  String input,
  String startMarker,
  String endMarker,
  String content,
  String path,
) {
  final start = input.indexOf(startMarker);
  final end = input.indexOf(endMarker);
  if (start == -1 && end == -1) {
    stdout.writeln(
      'Upstream version tables are not configured in $path; skipping.',
    );
    return input;
  }
  if (start == -1 || end == -1 || end < start) {
    stderr.writeln('Incomplete upstream version table markers in $path');
    exit(3);
  }

  return input.replaceRange(start + startMarker.length, end, content);
}

String _renderParityTable(Map<String, Object?> parityData) {
  final parityRows = (parityData['kitParity'] as List<Object?>? ?? const [])
      .cast<Map<String, Object?>>();
  if (parityRows.isEmpty) {
    stderr.writeln('config/upstream-versions.json declares no kitParity rows.');
    exit(2);
  }

  final seen = <String>{};
  String? previous;
  for (final row in parityRows) {
    final version = '${row['solanaKit']}';
    if (!seen.add(version)) {
      stderr.writeln('Duplicate kitParity row for solana_kit $version.');
      exit(2);
    }
    if (previous != null && _compareVersions(version, previous) >= 0) {
      stderr.writeln(
        'kitParity rows must be ordered newest first: $version follows '
        '$previous.',
      );
      exit(2);
    }
    previous = version;
  }

  final rows = parityRows.map((row) {
    final jsKit = row['jsKit'];
    return <String>[
      '`${row['solanaKit']}`',
      if (jsKit == null) '—' else '`$jsKit`',
      '${row['released']}',
    ];
  }).toList();

  return _table(
    header: const ['`solana_kit`', '`@solana/kit`', 'Released'],
    rows: rows,
  );
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

/// Renders one table per upstream family, showing the ref each `solana_kit`
/// release was generated and verified against.
String _renderRepoPinTables(Map<String, Object?> parityData) {
  final families = (parityData['families'] as List<Object?>? ?? const [])
      .cast<Map<String, Object?>>();
  final rows = (parityData['repoPins'] as List<Object?>? ?? const [])
      .cast<Map<String, Object?>>();
  if (families.isEmpty || rows.isEmpty) {
    stderr.writeln(
      'config/upstream-versions.json declares no families or repoPins rows.',
    );
    exit(2);
  }

  final releases = rows.map((row) => '${row['solanaKit']}').toList();
  // A blank line separates the block marker from the first heading.
  final buffer = StringBuffer()..write('\n\n');
  for (final family in families) {
    final repos = (family['repos'] as List<Object?>? ?? const [])
        .cast<String>();
    final missing = repos.where(
      (repo) => !rows.any(
        (row) => (row['pins'] as Map<String, Object?>? ?? const {}).containsKey(
          repo,
        ),
      ),
    );
    if (missing.isNotEmpty) {
      stderr.writeln(
        'Family "${family['title']}" references repos with no pins: '
        '${missing.join(', ')}.',
      );
      exit(2);
    }

    buffer
      ..writeln('#### ${family['title']}')
      ..writeln(
        _table(
          header: ['`solana_kit`', ...repos],
          rows: [
            for (final row in rows)
              <String>[
                '`${row['solanaKit']}`',
                for (final repo in repos)
                  switch ((row['pins'] as Map<String, Object?>? ??
                      const {})[repo]) {
                    final String pin => '`$pin`',
                    _ => '—',
                  },
              ],
          ],
        ).trimRight(),
      )
      ..writeln();
  }

  // Validate that releases run newest first so the matrices stay readable.
  for (var index = 1; index < releases.length; index++) {
    if (_compareVersions(releases[index], releases[index - 1]) >= 0) {
      stderr.writeln(
        'repoPins rows must be ordered newest first: ${releases[index]} '
        'follows ${releases[index - 1]}.',
      );
      exit(2);
    }
  }

  return buffer.toString();
}

String _renderPinsTable(Map<String, Object?> referenceRepos) {
  final repos = (referenceRepos['repos'] as List<Object?>? ?? const [])
      .cast<Map<String, Object?>>();

  final rows = <List<String>>[];
  for (final repo in repos) {
    final ref = (repo['ref'] as Map<String, Object?>?) ?? const {};
    final checkedCommit = repo['checkedCommit'] as String?;
    final packages = switch (repo['packages']) {
      final List<Object?> list => list.cast<String>().toList()..sort(),
      _ => <String>[if (repo['package'] != null) '${repo['package']}'],
    };

    rows.add([
      '[${repo['name']}](${repo['url']})',
      _pinLabel('${ref['type']}', '${ref['value']}', checkedCommit),
      if (packages.isEmpty)
        '—'
      else
        packages.map((package) => '`$package`').join(', '),
    ]);
  }

  return _table(
    header: const ['Upstream repository', 'Pin', 'Dart package(s)'],
    rows: rows,
  );
}

String _pinLabel(String type, String value, String? checkedCommit) {
  final shortCommit = switch (checkedCommit) {
    final commit? when commit.length >= 12 => commit.substring(0, 12),
    _ => null,
  };

  return switch (type) {
    'tag' => '`$value`',
    'branch' when shortCommit != null => '`$value` ($shortCommit)',
    'commit' => '`${value.length > 12 ? value.substring(0, 12) : value}`',
    _ => '`$value`',
  };
}

String _table({
  required List<String> header,
  required List<List<String>> rows,
}) {
  final widths = List<int>.generate(header.length, (index) {
    var width = header[index].length;
    for (final row in rows) {
      if (row[index].length > width) width = row[index].length;
    }
    return width;
  });

  final buffer = StringBuffer()
    ..writeln()
    ..writeln('<!-- dprint-ignore -->')
    ..writeln(_row(header, widths))
    ..writeln(_row([for (final width in widths) '-' * width], widths));
  for (final row in rows) {
    buffer.writeln(_row(row, widths));
  }
  buffer.writeln();

  return buffer.toString();
}

String _row(List<String> cells, List<int> widths) {
  final padded = <String>[
    for (var index = 0; index < cells.length; index++)
      cells[index].padRight(widths[index]),
  ];
  return '| ${padded.join(' | ')} |';
}
