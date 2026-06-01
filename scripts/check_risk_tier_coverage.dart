import 'dart:convert';
import 'dart:io';

final Directory _repoRoot = Directory.current;
final _configPath = File('config/coverage-risk-tier-thresholds.json');

Future<void> main() async {
  final config =
      jsonDecode(_configPath.readAsStringSync()) as Map<String, Object?>;
  final packages = (config['packages']! as List).cast<Map<String, Object?>>();
  final failures = <String>[];

  stdout.writeln('Running risk-tier package coverage checks...');
  for (final packageConfig in packages) {
    final packageName = packageConfig['package']! as String;
    final risk = packageConfig['risk']! as String;
    final minimum = (packageConfig['minimumLineCoverage']! as num).toDouble();
    final packageDirectory = Directory(
      '${_repoRoot.path}/packages/$packageName',
    );
    final coverageDirectory = Directory('${packageDirectory.path}/coverage');
    final lcovFile = File('${coverageDirectory.path}/lcov.info');

    stdout.writeln(
      '\n[$risk] $packageName (min ${minimum.toStringAsFixed(0)}%)',
    );
    if (coverageDirectory.existsSync()) {
      coverageDirectory.deleteSync(recursive: true);
    }

    final result = await Process.start(
      'dart',
      ['run', 'coverage:test_with_coverage', 'test'],
      workingDirectory: packageDirectory.path,
      mode: ProcessStartMode.inheritStdio,
    );
    final exitCode = await result.exitCode;
    if (exitCode != 0) {
      failures.add('$packageName: coverage command exited with $exitCode');
      continue;
    }

    if (!lcovFile.existsSync()) {
      failures.add('$packageName: missing coverage/lcov.info output');
      continue;
    }

    final (linesHit, linesFound) = _parseLcov(lcovFile);
    final percentage = linesFound == 0 ? 100.0 : linesHit / linesFound * 100.0;
    stdout.writeln(
      '  line coverage: $linesHit/$linesFound (${percentage.toStringAsFixed(2)}%)',
    );

    if (percentage < minimum) {
      failures.add(
        '$packageName: ${percentage.toStringAsFixed(2)}% < required ${minimum.toStringAsFixed(0)}%',
      );
    }
  }

  if (failures.isNotEmpty) {
    stdout.writeln('\nCoverage threshold failures:');
    for (final failure in failures) {
      stdout.writeln('  - $failure');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('\nAll risk-tier package coverage floors passed.');
}

(int, int) _parseLcov(File lcovFile) {
  var totalFound = 0;
  var totalHit = 0;
  for (final block in lcovFile.readAsStringSync().split('end_of_record')) {
    final found = RegExp(r'LF:(\d+)').firstMatch(block);
    final hit = RegExp(r'LH:(\d+)').firstMatch(block);
    if (found != null && hit != null) {
      totalFound += int.parse(found.group(1)!);
      totalHit += int.parse(hit.group(1)!);
    }
  }
  return (totalHit, totalFound);
}
