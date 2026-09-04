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
