// ignore_for_file: cascade_invocations

import 'dart:convert';
import 'dart:io';

/// Runs mutation testing for a scoped set of high-risk source files.
///
/// `mutation-test` (https://pub.dev/packages/mutation_test) mutates source by
/// text replacement, runs a test command, and treats the mutant as killed when
/// that command exits non-zero. It has no notion of which tests actually
/// exercise a file, so a naive setup reports false survivors: mutate a shared
/// codec, run only that package's tests, and every mutant looks unkilled even
/// though the wider suite catches them. That failure mode is silent and makes
/// the whole report untrustworthy.
///
/// This driver removes the guesswork:
///
///   * Scopes live in `config/mutation/scopes.json`, pairing source files with
///     the test directories that can detect a change in them.
///   * The test list for a scope is verified against the workspace dependency
///     graph. `--check` reports any transitive dependent whose tests are
///     missing, so a scope cannot silently fall behind the dependency graph.
///   * Only the requested scope runs, keeping a mutant's cost to that scope's
///     test time instead of the whole workspace.
///
/// Usage:
///
///   dart run scripts/run_mutation_testing.dart --list
///   dart run scripts/run_mutation_testing.dart --scope codecs_numbers
///   dart run scripts/run_mutation_testing.dart --scope codecs_numbers --check
///   dart run scripts/run_mutation_testing.dart --changed
///   dart run scripts/run_mutation_testing.dart --scope keys --coverage
Future<void> main(List<String> args) async {
  final options = _Options.parse(args);
  final root = Directory.current;

  if (options.list) {
    _printScopes(root);
    return;
  }

  if (options.check) {
    exitCode = _checkScopeDrift(root, options.scope);
    return;
  }

  final scopes = _loadScopes(root);

  if (scopes.isEmpty) {
    stderr.writeln(
      'No scopes found in config/mutation/scopes.json. Nothing to mutate.',
    );
    exitCode = 1;
    return;
  }

  final List<_Scope> selected;

  if (options.changed) {
    selected = _scopesForChangedFiles(root, scopes);
  } else {
    selected = _selectScopes(scopes, options.scope);
  }

  if (selected.isEmpty) {
    stdout.writeln('No mutation scope selected; nothing to do.');
    return;
  }

  final mutationTestReady = await _ensureMutationTest(root);

  if (!mutationTestReady) {
    exitCode = 1;
    return;
  }

  final reverseDependencies = options.full
      ? _reverseDependencies(root)
      : const <String, Set<String>>{};

  final failures = <String>[];

  for (final scope in selected) {
    final tests = options.full
        ? _testsForFullRun(root, scope, reverseDependencies)
        : scope.existingTests(root);
    final code = await _runScope(root, scope, options, tests);

    if (code != 0) {
      failures.add(scope.name);
    }
  }

  if (failures.isNotEmpty) {
    stderr.writeln(
      '\nMutation runs that did not complete: ${failures.join(', ')}',
    );
    exitCode = 1;
  }
}

/// A named group of source files plus the tests that exercise them.
class _Scope {
  _Scope({
    required this.name,
    required this.note,
    required this.source,
    required this.tests,
  });

  final String name;
  final String note;
  final List<String> source;
  final List<String> tests;

  /// Source files that exist on disk, so a stale entry is reported rather than
  /// silently reducing coverage.
  List<String> existingSources(Directory root) {
    final files = <String>[];

    for (final entry in source) {
      final entity = FileSystemEntity.typeSync('${root.path}/$entry');

      if (entity == FileSystemEntityType.file) {
        files.add(entry);

      } else if (entity == FileSystemEntityType.directory) {
        files.addAll(
          _dartFilesUnder(
            Directory('${root.path}/$entry'),
          ).map((file) => _relative(root, file.path)),
        );
      } else {
        stderr.writeln(
          '  warning: scope "$name" lists a missing source path: $entry',
        );
      }
    }
    files.sort();
    return files;
  }

  List<String> existingTests(Directory root) => tests
      .where(
        (test) => Directory('${root.path}/$test').existsSync(),
      )
      .toList();
}

Future<int> _runScope(
  Directory root,
  _Scope scope,
  _Options options,
  List<String> tests,
) async {
  final source = scope.existingSources(root);

  if (source.isEmpty) {
    stderr.writeln('Scope "${scope.name}" has no existing source files.');
    return 1;
  }

  if (tests.isEmpty) {
    stderr.writeln(
      'Scope "${scope.name}" has no existing test directories, so no mutant '
      'could be killed. Fix the scope before running it.',
    );
    return 1;
  }

  final reportDirectory = Directory(
    '${root.path}/coverage/mutation/${scope.name}',
  );

  if (reportDirectory.existsSync()) {
    reportDirectory.deleteSync(recursive: true);
  }
  reportDirectory.createSync(recursive: true);

  // Two things have to be configured together, and both are easy to get wrong:
  //
  //   1. `mutation-test` splits a <command> on single spaces and runs the first
  //      token as the executable, so a multi-argument command fails with a bare
  //      ProcessException. The test command is therefore a generated script.
  //   2. Positional arguments on the command line are all treated as mutation
  //      targets. Passing the runner script positionally mutates the runner
  //      itself, which burns test runs and reports nonsense. Sources are
  //      declared through the generated config's <files> block instead.
  final supportDirectory = Directory('${root.path}/.dart_tool/mutation-test')
    ..createSync(recursive: true);
  final runner = File('${supportDirectory.path}/run-${scope.name}.sh')
    ..writeAsStringSync(_testRunnerScript(root, tests));
  final config = File('${supportDirectory.path}/${scope.name}.xml')
    ..writeAsStringSync(_scopeConfig(scope, source, runner));

  // Passing `--rules` already disables the builtin rule set, which is what we
  // want: the builtin `<` and `>` rules also match the first character of `<<`
  // and `>>`, producing mutants that are not valid Dart.
  final command = StringBuffer()
    ..write('dart run mutation_test ')
    ..write('--rules ${_quote('${root.path}/config/mutation/rules.xml')} ')
    ..write('--output ${_quote(reportDirectory.path)} ');

  if (options.coverage) {
    command.write('--coverage ${_quote('${root.path}/coverage/lcov.info')} ');
  }
  command.write(_quote(config.path));

  stdout
    ..writeln()
    ..writeln('=== mutation scope: ${scope.name} ===')
    ..writeln(scope.note)
    ..writeln(
      'mutating ${source.length} file(s) against ${tests.length} test dir(s)',
    )
    ..writeln();

  final result = await Process.start(
    'bash',
    ['-lc', command.toString()],
    workingDirectory: root.path,
    mode: ProcessStartMode.inheritStdio,
  );
  return result.exitCode;
}

/// Builds the per-scope `mutation-test` config.
///
/// Sources are declared under `<files>` rather than passed as positional
/// arguments, so the runner script cannot accidentally become a mutation
/// target. Paths stay relative to the repository root: the tool resolves them
/// against its working directory and prints them verbatim in the HTML report,
/// so absolute paths would make the report unreadable.
String _scopeConfig(_Scope scope, List<String> sources, File runner) {
  final files = sources.map((path) => '    <file>$path</file>').join('\n');
  return '''
<?xml version="1.0" encoding="UTF-8"?>
<!--
  Generated by scripts/run_mutation_testing.dart for the "${scope.name}" scope.
  Do not edit here; edit config/mutation/scopes.json instead.
-->
<mutations version="1.2">
  <files>
$files
  </files>

  <commands>
    <command group="test" expected="0" working-directory="." timeout="900">/bin/sh ${runner.path}</command>
  </commands>
</mutations>
''';
}

/// Builds the shell script `mutation-test` runs to decide whether a mutant was
/// killed.
///
/// `--reporter=failures-only` keeps the output small: a mutant run happens once
/// per mutation, so the full reporter would flood the terminal. The exit code
/// is what matters, and that is preserved.
String _testRunnerScript(Directory root, List<String> tests) {
  final quoted = tests.map(_quote).join(' ');
  return '''
#!/bin/sh
# Generated by scripts/run_mutation_testing.dart. Do not edit by hand.
cd ${_quote(root.path)} || exit 2
exec dart test --exclude-tags integration --reporter=failures-only $quoted
''';
}

/// Reports how completely a scope's test list covers its dependents.
///
/// Two different questions matter, and conflating them makes the tool either
/// uselessly slow or silently wrong:
///
///   * Which tests must run for the survivors to be trustworthy? Strictly, a
///     mutant in a shared package can be killed by any dependent's tests. For
///     `solana_kit_codecs_numbers` that is 58 packages, and running all of them
///     per mutant costs ~75s instead of ~2s.
///   * Which tests should run by default? The scope's own list, tuned to the
///     tests that actually exercise the code.
///
/// So a missing dependent is not an error, it is a caveat: survivors reported
/// for code that other packages exercise may be false positives. This reports
/// the size of that caveat and exits non-zero only when a scope is broken
/// (a missing source or test path), which is a real configuration error.
int _checkScopeDrift(Directory root, String? only) {
  final scopes = _loadScopes(root);
  final reverseDependencies = _reverseDependencies(root);
  var broken = 0;

  for (final scope in scopes.values) {
    if (only != null && scope.name != only) continue;

    final sourcePackages = scope.source
        .map(_packageOf)
        .whereType<String>()
        .toSet();
    final coveredPackages = scope.tests
        .map(_packageOf)
        .whereType<String>()
        .toSet();

    final missing = <String>{};

    for (final package in sourcePackages) {
      for (final dependent in _transitiveDependents(
        package,
        reverseDependencies,
      )) {
        if (!coveredPackages.contains(dependent)) {
          missing.add(dependent);
        }
      }
    }

    // A scope with no runnable tests cannot produce a meaningful result.
    final runnable = scope.existingTests(root);

    if (runnable.isEmpty) {
      broken++;
      stdout.writeln('  broken ${scope.name}: no test directory exists');
      continue;
    }

    for (final entry in scope.source) {
      if (FileSystemEntity.typeSync('${root.path}/$entry') ==
          FileSystemEntityType.notFound) {
        broken++;
        stdout.writeln('  broken ${scope.name}: missing source $entry');
      }
    }

    if (missing.isEmpty) {
      stdout.writeln('  exact  ${scope.name} (all dependents covered)');
    } else {
      stdout.writeln(
        '  partial ${scope.name}: ${missing.length} dependent package(s) '
        'outside the test list',
      );
      stdout.writeln(
        '          survivors may include false positives; '
        'use --full for an authoritative run',
      );
    }
  }

  if (broken > 0) {
    stdout.writeln('\n$broken scope(s) are misconfigured.');
    return 1;
  }
  stdout.writeln(
    '\nNo scope is misconfigured. "partial" scopes trade accuracy for speed.',
  );
  return 0;
}

/// Expands a scope's test list to every transitive dependent that has tests.
///
/// This is what makes a survivor authoritative: a mutant in a shared codec can
/// be killed by any dependent's suite, so excluding them is what produces false
/// positives. The cost is that each mutant now runs the bulk of the workspace
/// (~75s rather than ~2s), which is why this is opt-in via `--full`.
List<String> _testsForFullRun(
  Directory root,
  _Scope scope,
  Map<String, Set<String>> reverseDependencies,
) {
  final directories = <String>{...scope.existingTests(root)};
  final sourcePackages = scope.source.map(_packageOf).whereType<String>();

  for (final package in sourcePackages) {
    for (final dependent in _transitiveDependents(
      package,
      reverseDependencies,
    )) {
      // Integration tests need a validator and are excluded from the runner
      // script's tag filter, so listing them would only add startup cost.
      if (dependent == 'solana_kit_integration_tests') continue;
      final testDirectory = 'packages/$dependent/test';

      if (Directory('${root.path}/$testDirectory').existsSync()) {
        directories.add(testDirectory);
      }
    }
  }
  final sorted = directories.toList()..sort();
  return sorted;
}

/// Reads the internal dependency graph and inverts it.
Map<String, Set<String>> _reverseDependencies(Directory root) {
  final reverse = <String, Set<String>>{};

  for (final packageDirectory in _packageDirectories(root)) {
    final pubspec = File('${packageDirectory.path}/pubspec.yaml');

    if (!pubspec.existsSync()) continue;
    final text = pubspec.readAsStringSync();
    final name = _pubspecName(text);

    if (name == null) continue;
    reverse.putIfAbsent(name, () => <String>{});

    for (final dependency in _pubspecDependencies(text)) {
      reverse.putIfAbsent(dependency, () => <String>{}).add(name);
    }
  }
  return reverse;
}

Set<String> _transitiveDependents(
  String package,
  Map<String, Set<String>> reverse,
) {
  final seen = <String>{};
  final stack = <String>[package];

  while (stack.isNotEmpty) {
    final current = stack.removeLast();

    for (final dependent in reverse[current] ?? const <String>{}) {
      if (seen.add(dependent)) {
        stack.add(dependent);
      }
    }
  }
  // A package is not its own dependent.
  seen.remove(package);
  return seen;
}

List<_Scope> _scopesForChangedFiles(
  Directory root,
  Map<String, _Scope> scopes,
) {
  final result = _run('git', [
    'diff',
    '--name-only',
    'origin/main...HEAD',
  ], workingDirectory: root.path);

  if (result == null) {
    stderr.writeln(
      'Could not read `git diff origin/main...HEAD`. Pass --scope instead.',
    );
    return const [];
  }

  final changed = result
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  if (changed.isEmpty) return const [];

  final selected = <String, _Scope>{};

  for (final scope in scopes.values) {
    final touched = scope.source.any(
      (entry) => changed.any(
        (file) => file == entry || file.startsWith('$entry/'),
      ),
    );

    if (touched) selected[scope.name] = scope;
  }

  if (selected.isEmpty) {
    stdout.writeln(
      'No changed file falls inside a mutation scope; nothing to do.',
    );
  } else {
    stdout.writeln(
      'Changed files select ${selected.length} scope(s): '
      '${selected.keys.join(', ')}',
    );
  }
  return selected.values.toList();
}

List<_Scope> _selectScopes(Map<String, _Scope> scopes, String? name) {
  if (name == null) return scopes.values.toList();
  final scope = scopes[name];

  if (scope == null) {
    stderr.writeln(
      'Unknown scope "$name". Available scopes: ${scopes.keys.join(', ')}',
    );
    return const [];
  }
  return [scope];
}

void _printScopes(Directory root) {
  final scopes = _loadScopes(root);
  stdout.writeln('${scopes.length} mutation scope(s):\n');

  for (final scope in scopes.values) {
    final sources = scope.existingSources(root);
    final tests = scope.existingTests(root);
    final lines = sources.fold<int>(
      0,
      (total, path) =>
          total + File('${root.path}/$path').readAsLinesSync().length,
    );
    stdout
      ..writeln(scope.name)
      ..writeln('  files: ${sources.length} ($lines lines)')
      ..writeln('  tests: ${tests.length} directories')
      ..writeln();
  }
}

Future<bool> _ensureMutationTest(Directory root) async {
  final result = await Process.run(
    'dart',
    ['run', 'mutation_test', '--version'],
    workingDirectory: root.path,
  );

  if (result.exitCode == 0) return true;
  stderr
    ..writeln('`mutation_test` is not available.')
    ..writeln('Run `dart pub get` at the repository root, then retry.')
    ..write(result.stderr);
  return false;
}

/// Reads the scope definitions.
///
/// The file is JSON so it can be parsed by `dart:convert` and formatted by the
/// repository's dprint config, which formats `.yaml` as machine YAML and cannot
/// represent the prose that explains why each scope exists.
///
/// Validation is explicit rather than advisory: a scope with no source or no
/// tests is a configuration error, because a scope that cannot run would report
/// every mutant as surviving.
Map<String, _Scope> _loadScopes(Directory root) {
  final file = File('${root.path}/config/mutation/scopes.json');

  if (!file.existsSync()) {
    throw StateError(
      'Missing config/mutation/scopes.json. Mutation testing needs a scope '
      'definition to know which tests can kill a mutant.',
    );
  }

  final Object? decoded;
  try {
    decoded = jsonDecode(file.readAsStringSync());

  } on FormatException catch (error) {
    throw StateError('config/mutation/scopes.json is not valid JSON: $error');
  }
  final map = decoded is Map<String, Object?> ? decoded : null;
  final rawScopes = map?['scopes'];

  if (rawScopes is! Map<String, Object?>) {
    throw StateError(
      'config/mutation/scopes.json must contain a top-level `scopes` object.',
    );
  }

  final scopes = <String, _Scope>{};

  for (final entry in rawScopes.entries) {
    final name = entry.key;
    final value = entry.value;

    if (value is! Map<String, Object?>) {
      throw StateError('Scope "$name" must be an object.');
    }
    final source = (value['source'] as List<Object?>? ?? const [])
        .cast<String>()
        .toList();
    final tests = (value['tests'] as List<Object?>? ?? const [])
        .cast<String>()
        .toList();

    if (source.isEmpty || tests.isEmpty) {
      throw StateError(
        'Scope "$name" must define at least one source and one test entry.',
      );
    }
    scopes[name] = _Scope(
      name: name,
      note: (value['note'] as String?) ?? '',
      source: source,
      tests: tests,
    );
  }

  if (scopes.isEmpty) {
    throw StateError('config/mutation/scopes.json defined no scopes.');
  }
  return scopes;
}

List<File> _dartFilesUnder(Directory directory) {
  if (!directory.existsSync()) return const [];
  return directory
      .listSync(recursive: true, followLinks: false)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();
}

List<Directory> _packageDirectories(Directory root) {
  final packages = Directory('${root.path}/packages');

  if (!packages.existsSync()) return const [];
  return packages
      .listSync()
      .whereType<Directory>()
      .where((directory) => File('${directory.path}/pubspec.yaml').existsSync())
      .toList()
    ..sort((left, right) => left.path.compareTo(right.path));
}

String? _pubspecName(String pubspec) {
  final match = RegExp(r'^name:\s*(\S+)', multiLine: true).firstMatch(pubspec);
  return match?.group(1);
}

/// Names under the top-level `dependencies:` block only.
///
/// Dev dependencies are excluded: a package's tests do not ship, so a dev-only
/// dependent cannot make a change to this package observable in production
/// code, and including them would pull the whole workspace into every scope.
Set<String> _pubspecDependencies(String pubspec) {
  final start = pubspec.indexOf(RegExp('^dependencies:', multiLine: true));

  if (start < 0) return const {};
  final rest = pubspec.substring(start + 'dependencies:'.length);
  final block = <String>[];

  for (final line in rest.split('\n')) {
    if (line.trim().isEmpty) continue;
    // A new top-level key ends the block.
    if (line.startsWith(RegExp('[a-zA-Z]'))) break;
    block.add(line);
  }
  return RegExp(
    '^  ([a-z_0-9]+):',
    multiLine: true,
  ).allMatches(block.join('\n')).map((match) => match.group(1)!).toSet();
}

String? _packageOf(String path) {
  final match = RegExp('^packages/([a-z_0-9]+)').firstMatch(path);
  return match?.group(1);
}

String _relative(Directory root, String path) =>
    path.startsWith('${root.path}/')
    ? path.substring(root.path.length + 1)
    : path;

String _quote(String value) => "'${value.replaceAll("'", r"'\''")}'";

String? _run(
  String executable,
  List<String> arguments, {
  required String workingDirectory,
}) {
  final result = Process.runSync(
    executable,
    arguments,
    workingDirectory: workingDirectory,
  );

  if (result.exitCode != 0) return null;
  return result.stdout as String;
}

class _Options {
  factory _Options.parse(List<String> args) {
    String? scope;
    var list = false;
    var check = false;
    var changed = false;
    var coverage = false;
    var full = false;

    for (var index = 0; index < args.length; index++) {
      final arg = args[index];

      switch (arg) {
        case '--scope':
          if (index + 1 >= args.length) {
            throw ArgumentError('--scope requires a scope name.');
          }
          scope = args[++index];

        case '--list':
          list = true;

        case '--check':
          check = true;

        case '--changed':
          changed = true;

        case '--coverage':
          coverage = true;

        case '--full':
          full = true;

        case '--help' || '-h':
          _printUsage();
          exit(0);

        default:
          if (arg.startsWith('--scope=')) {
            scope = arg.substring('--scope='.length);
          } else {
            throw ArgumentError('Unknown argument: $arg');
          }
      }
    }
    return _Options._(
      scope: scope,
      list: list,
      check: check,
      changed: changed,
      coverage: coverage,
      full: full,
    );
  }
  _Options._({
    required this.scope,
    required this.list,
    required this.check,
    required this.changed,
    required this.coverage,
    required this.full,
  });

  final String? scope;
  final bool list;
  final bool check;
  final bool changed;
  final bool coverage;
  final bool full;

  static void _printUsage() {
    stdout.writeln('''
Runs scoped mutation testing over the SDK's highest-risk source files.

  --list              Show the configured scopes and their sizes.
  --scope <name>      Run one scope. Omit to run every scope.
  --check             Verify each scope's test list covers its dependents.
  --changed           Run only scopes touched by `git diff origin/main...HEAD`.
  --coverage          Pass merged coverage/lcov.info so uncovered lines are
                      skipped, which shortens a run.
  --full              Run every transitive dependent's tests, so no survivor
                      is a false positive. Much slower: the cost per mutant
                      becomes the workspace test time, not the scope's.

Examples:
  dart run scripts/run_mutation_testing.dart --list
  dart run scripts/run_mutation_testing.dart --check
  dart run scripts/run_mutation_testing.dart --scope codecs_numbers
  dart run scripts/run_mutation_testing.dart --changed --coverage
''');
  }
}
