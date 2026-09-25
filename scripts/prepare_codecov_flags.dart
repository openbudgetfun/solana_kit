import 'dart:convert';
import 'dart:io';

/// Split LCOV coverage into Codecov flag files by package path.
void main(List<String> arguments) {
  final options = _Options.parse(arguments);
  final outputDirectory = Directory(options.outputDirectory)
    ..createSync(recursive: true);
  final packages = _discoverPackages()
    ..['codama_renderers_dart'] = 'packages/codama-renderers-dart';

  final recordsByFlag = {for (final flag in packages.keys) flag: <String>[]};

  final lcovFile = File(options.lcovPath);
  if (lcovFile.existsSync()) {
    for (final record in _lcovRecords(lcovFile.readAsStringSync())) {
      final sourcePath = _recordSourcePath(record);
      if (sourcePath == null) continue;

      for (final entry in packages.entries) {
        final packagePath = entry.value;
        if (sourcePath == packagePath ||
            sourcePath.startsWith('$packagePath/')) {
          recordsByFlag[entry.key]!.add(record);
          break;
        }
      }
    }
  }

  final npmLcovFile = File('packages/codama-renderers-dart/coverage/lcov.info');
  if (npmLcovFile.existsSync()) {
    recordsByFlag['codama_renderers_dart']!.addAll(
      _lcovRecords(npmLcovFile.readAsStringSync()),
    );
  }

  final writtenFlags = <String>[];
  for (final entry in recordsByFlag.entries) {
    if (entry.value.isEmpty) continue;

    File(
      '${outputDirectory.path}/${entry.key}.lcov',
    ).writeAsStringSync(entry.value.join());
    writtenFlags.add(entry.key);
  }

  final flagsJson = jsonEncode(writtenFlags);
  if (options.githubOutputPath != null) {
    File(
      options.githubOutputPath!,
    ).writeAsStringSync('flags=$flagsJson\n', mode: FileMode.append);
  }

  stdout.writeln(flagsJson);
}

Map<String, String> _discoverPackages() {
  final packagesDirectory = Directory('packages');
  if (!packagesDirectory.existsSync()) return {};

  final packages = <String, String>{};
  final pubspecs =
      packagesDirectory
          .listSync()
          .whereType<Directory>()
          .map((directory) => File('${directory.path}/pubspec.yaml'))
          .where((file) => file.existsSync())
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));

  for (final pubspec in pubspecs) {
    final name = _packageName(pubspec);
    if (name != null) {
      packages[name] = pubspec.parent.path.replaceAll(
        String.fromCharCode(92),
        '/',
      );
    }
  }

  return packages;
}

String? _packageName(File pubspec) {
  for (final line in pubspec.readAsLinesSync()) {
    final match = RegExp(r'^name:\s*([^\s#]+)').firstMatch(line);
    if (match != null) {
      return match.group(1);
    }
  }

  return null;
}

List<String> _lcovRecords(String contents) {
  final records = <String>[];
  final current = <String>[];

  for (final line in const LineSplitter().convert(contents)) {
    current.add(line);
    if (line == 'end_of_record') {
      records.add('${current.join('\n')}\n');
      current.clear();
    }
  }

  return records;
}

String? _recordSourcePath(String record) {
  for (final line in const LineSplitter().convert(record)) {
    if (!line.startsWith('SF:')) {
      continue;
    }

    var path = line
        .substring(3)
        .trim()
        .replaceAll(String.fromCharCode(92), '/');
    const marker = '/packages/';
    if (path.contains(marker)) {
      path = 'packages/${path.split(marker).last}';
    }
    if (path.startsWith('./')) {
      path = path.substring(2);
    }
    return path;
  }

  return null;
}

final class _Options {
  const _Options({
    required this.lcovPath,
    required this.outputDirectory,
    required this.githubOutputPath,
  });

  factory _Options.parse(List<String> arguments) {
    var lcovPath = 'coverage/lcov.info';
    var outputDirectory = 'coverage/flags';
    String? githubOutputPath;

    for (var index = 0; index < arguments.length; index += 1) {
      final argument = arguments[index];
      switch (argument) {
        case '--lcov':
          lcovPath = _requiredValue(arguments, index);
          index += 1;
        case '--out-dir':
          outputDirectory = _requiredValue(arguments, index);
          index += 1;
        case '--github-output':
          githubOutputPath = _requiredValue(arguments, index);
          index += 1;
        default:
          throw ArgumentError('Unknown argument: $argument');
      }
    }

    return _Options(
      lcovPath: lcovPath,
      outputDirectory: outputDirectory,
      githubOutputPath: githubOutputPath,
    );
  }

  final String lcovPath;
  final String outputDirectory;
  final String? githubOutputPath;

  static String _requiredValue(List<String> arguments, int index) {
    if (index + 1 >= arguments.length) {
      throw ArgumentError('Missing value for ${arguments[index]}');
    }

    return arguments[index + 1];
  }
}
