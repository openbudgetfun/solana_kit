import 'package:solana_kit_mpl_token_metadata/solana_kit_mpl_token_metadata.dart';
import 'package:test/test.dart';

void main() {
  group('MplTokenMetadata error codes', () {
    test('match the hex values in the generated errors', () {
      expect(mplTokenMetadataErrorInstructionUnpackError, 0x0);
      expect(mplTokenMetadataErrorNotRentExempt, 0x2);
      expect(mplTokenMetadataErrorInvalidMetadataKey, 0x5);
      expect(mplTokenMetadataErrorUpdateAuthorityIncorrect, 0x7);
      expect(mplTokenMetadataErrorNameTooLong, 0xb);
      expect(mplTokenMetadataErrorSymbolTooLong, 0xc);
      expect(mplTokenMetadataErrorUriTooLong, 0xd);
      expect(mplTokenMetadataErrorDataIsImmutable, 0x3b);
      expect(mplTokenMetadataErrorCollectionNotFound, 0x50);
      expect(mplTokenMetadataErrorInvalidEditionIndex, 0x47);
      expect(mplTokenMetadataErrorInvalidBubblegumSigner, 0x84);
      expect(mplTokenMetadataErrorInvalidInstruction, 0xbd);
      expect(mplTokenMetadataErrorConditionsForClosingNotMet, 0xca);
    });

    test('match their decimal documentation comments', () {
      expect(mplTokenMetadataErrorNameTooLong, 11);
      expect(mplTokenMetadataErrorUriTooLong, 13);
      expect(mplTokenMetadataErrorCollectionNotFound, 80);
      expect(mplTokenMetadataErrorConditionsForClosingNotMet, 202);
    });
  });

  group('getMplTokenMetadataErrorMessage', () {
    test('returns the message for known error codes', () {
      expect(getMplTokenMetadataErrorMessage(11), equals('Name too long'));
      expect(getMplTokenMetadataErrorMessage(13), equals('URI too long'));
      expect(getMplTokenMetadataErrorMessage(59), equals('Data is immutable'));
      expect(
        getMplTokenMetadataErrorMessage(80),
        equals('Collection Not Found on Metadata'),
      );
    });

    test('returns null for unknown error codes', () {
      expect(getMplTokenMetadataErrorMessage(0xfff), isNull);
      expect(getMplTokenMetadataErrorMessage(-1), isNull);
      expect(getMplTokenMetadataErrorMessage(10000), isNull);
    });
  });

  group('isMplTokenMetadataError', () {
    test('returns true for program error codes', () {
      expect(isMplTokenMetadataError(0), isTrue);
      expect(isMplTokenMetadataError(11), isTrue);
      expect(isMplTokenMetadataError(202), isTrue);
    });

    test('returns false for other programs error codes', () {
      expect(isMplTokenMetadataError(10000), isFalse);
      expect(isMplTokenMetadataError(-1), isFalse);
      expect(isMplTokenMetadataError(6000), isFalse);
    });
  });
}
