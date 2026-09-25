import 'dart:io';

import 'package:solana_kit_keys/solana_kit_keys.dart';
import 'package:test/test.dart';

import 'setup.dart';

void main() {
  group('key file publication security', () {
    late Directory directory;
    late KeyPair keyPair;
    final realIO = _RealIOOverrides();

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('keyfile-security-');
      keyPair = createKeyPairFromBytes(mockKeyBytes);
    });

    tearDown(() async {
      keyPair.dispose();
      await directory.delete(recursive: true);
    });

    for (final overwrite in [false, true]) {
      test('does not write through a replaced destination, overwrite '
          '$overwrite', () async {
        if (Platform.isWindows) return;
        final destination = File('${directory.path}/keypair.json');
        final unrelated = File('${directory.path}/unrelated.json');
        await unrelated.writeAsString('unrelated data');
        final intercepted = _FileAfterCreate(destination, () async {
          await destination.delete();
          await Link(destination.path).create(unrelated.path);
        });

        await IOOverrides.runZoned(
          () => writeKeyPair(
            keyPair,
            destination.path,
            unsafelyOverwriteExistingKeyPair: overwrite,
          ),
          createFile: (path) =>
              path == destination.path ? intercepted : realIO.createFile(path),
        );

        expect(await unrelated.readAsString(), 'unrelated data');
        expect(
          FileSystemEntity.typeSync(destination.path, followLinks: false),
          FileSystemEntityType.file,
        );
      });
    }

    test('cleans up staging if restricting file permissions fails', () async {
      if (Platform.isWindows) return;
      final destination = File('${directory.path}/keypair.json');

      await expectLater(
        IOOverrides.runZoned(
          () => writeKeyPair(keyPair, destination.path),
          createFile: (path) {
            final file = realIO.createFile(path);
            if (path == destination.path) return file;
            expect(file.parent.statSync().mode & 0x1ff, 0x1c0);
            return _FileAfterCreate(file, () async {
              // Model the staged file disappearing before chmod completes.
              await file.delete();
            });
          },
        ),
        throwsA(
          isA<FileSystemException>().having(
            (error) => error.message,
            'message',
            'Failed to restrict key pair file permissions',
          ),
        ),
      );

      expect(await directory.list().toList(), isEmpty);
    });

    test(
      'restricts the staging directory before creating the key file',
      () async {
        if (Platform.isWindows) return;
        final destination = File('${directory.path}/keypair.json');
        final parent = _DirectoryWithTempMode(directory, '755');
        final intercepted = _FileWithParent(destination, parent);
        var inspectedStagingDirectory = false;

        await IOOverrides.runZoned(
          () => writeKeyPair(keyPair, destination.path),
          createFile: (path) {
            if (path == destination.path) return intercepted;
            final file = realIO.createFile(path);
            inspectedStagingDirectory = true;
            expect(file.parent.statSync().mode & 0x1ff, 0x1c0);
            return file;
          },
        );

        expect(inspectedStagingDirectory, isTrue);
      },
    );

    test('reports a staging directory permission failure', () async {
      if (Platform.isWindows) return;
      final destination = File('${directory.path}/keypair.json');
      final parent = _DirectoryWithMissingTemp(directory);
      final intercepted = _FileWithParent(destination, parent);

      await expectLater(
        IOOverrides.runZoned(
          () => writeKeyPair(keyPair, destination.path),
          createFile: (path) =>
              path == destination.path ? intercepted : realIO.createFile(path),
        ),
        throwsA(
          isA<FileSystemException>().having(
            (error) => error.message,
            'message',
            'Failed to restrict key pair staging directory permissions',
          ),
        ),
      );

      expect(await directory.list().toList(), isEmpty);
    });

    test(
      'an early reader of the reservation cannot read the private key',
      () async {
        final destination = File('${directory.path}/keypair.json');
        late RandomAccessFile earlyReader;
        final intercepted = _FileAfterCreate(destination, () async {
          earlyReader = await destination.open();
        });

        await IOOverrides.runZoned(
          () => writeKeyPair(keyPair, destination.path),
          createFile: (path) =>
              path == destination.path ? intercepted : realIO.createFile(path),
        );
        addTearDown(earlyReader.close);

        expect(await earlyReader.read(4096), isEmpty);
        expect(await directory.list().length, 1);
      },
    );
  });
}

final class _RealIOOverrides extends IOOverrides {}

/// Interleaves another filesystem user immediately after destination creation.
class _FileAfterCreate implements File {
  _FileAfterCreate(this.file, this.afterCreate);

  final File file;
  final Future<void> Function() afterCreate;

  @override
  String get path => file.path;

  @override
  Directory get parent => file.parent;

  @override
  Future<File> create({bool recursive = false, bool exclusive = false}) async {
    await file.create(recursive: recursive, exclusive: exclusive);
    await afterCreate();
    return this;
  }

  @override
  Future<RandomAccessFile> open({FileMode mode = FileMode.read}) =>
      file.open(mode: mode);

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _FileWithParent implements File {
  const _FileWithParent(this.file, this.parent);

  final File file;

  @override
  final Directory parent;

  @override
  String get path => file.path;

  @override
  Future<File> create({bool recursive = false, bool exclusive = false}) =>
      file.create(recursive: recursive, exclusive: exclusive);

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _DirectoryWithTempMode implements Directory {
  const _DirectoryWithTempMode(this.directory, this.mode);

  final Directory directory;
  final String mode;

  @override
  String get path => directory.path;

  @override
  Future<Directory> create({bool recursive = false}) =>
      directory.create(recursive: recursive);

  @override
  Future<Directory> createTemp([String? prefix]) async {
    final created = await directory.createTemp(prefix);
    final chmod = await Process.run('chmod', [mode, created.path]);
    if (chmod.exitCode != 0) {
      throw FileSystemException(
        'Failed to prepare test directory',
        created.path,
      );
    }
    return created;
  }

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _DirectoryWithMissingTemp implements Directory {
  const _DirectoryWithMissingTemp(this.directory);

  final Directory directory;

  @override
  String get path => directory.path;

  @override
  Future<Directory> create({bool recursive = false}) =>
      directory.create(recursive: recursive);

  @override
  Future<Directory> createTemp([String? prefix]) async =>
      _MissingDirectory('${directory.path}/missing');

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class _MissingDirectory implements Directory {
  const _MissingDirectory(this.path);

  @override
  final String path;

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) async => this;

  @override
  Object? noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
