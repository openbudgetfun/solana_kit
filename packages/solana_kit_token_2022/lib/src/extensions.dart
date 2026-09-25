import 'package:solana_kit_codecs_core/solana_kit_codecs_core.dart';
import 'package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart';
import 'package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart';

import 'package:solana_kit_token_2022/src/generated/types/extension.dart';

export 'package:solana_kit_token_2022/src/generated/types/extension.dart'
    show Extension;

/// The list of extensions stored in the TLV region of a `Mint` or `Token`
/// account.
typedef Extensions = List<Extension>;

/// The number of bytes used by the `type` header of a TLV entry
/// (`ExtensionType` is a `u16`).
const _extensionTypeSize = 2;

/// The discriminator of the `Uninitialized` extension type, used as padding at
/// the end of the TLV region.
const _uninitializedExtensionType = 0;

/// Encodes the extensions of a `Mint` or `Token` account as consecutive TLV
/// entries.
///
/// The encoder adds no padding of its own; the program appends `Uninitialized`
/// padding when needed (for example, to avoid colliding with the `Multisig`
/// account length). An explicit `ExtensionUninitialized` entry still encodes as
/// a two-byte header.
Encoder<Extensions> getExtensionsEncoder() {
  return getArrayEncoder<Extension>(
    getExtensionEncoder(),
    size: const RemainderArraySize(),
  );
}

/// Decodes the extensions of a `Mint` or `Token` account from its TLV region.
///
/// Mirrors the program's `try_for_each_tlv_extension_type`: entries are read
/// one after the other until an `Uninitialized` (type `0`) header is found or
/// fewer than two bytes remain. Anything after that point is unused space and
/// is ignored, so accounts allocated with spare room (of any size, including
/// odd or two-byte multisig padding) decode correctly.
///
/// `Uninitialized` padding entries are never included in the decoded list.
///
/// The TLV region is expected to extend to the end of the buffer: the decoder
/// consumes any trailing bytes, so it must be the last field of the enclosing
/// struct.
Decoder<Extensions> getExtensionsDecoder() {
  final extensionDecoder = getExtensionDecoder();
  final extensionTypeDecoder = getU16Decoder();

  return VariableSizeDecoder<Extensions>(
    read: (bytes, startOffset) {
      var offset = startOffset;
      final extensions = <Extension>[];
      while (offset + _extensionTypeSize <= bytes.length) {
        final (extensionType, _) = extensionTypeDecoder.read(bytes, offset);
        if (extensionType == _uninitializedExtensionType) break;
        final (extension, nextOffset) = extensionDecoder.read(bytes, offset);
        extensions.add(extension);
        offset = nextOffset;
      }
      // Consume the remaining (unused) bytes so the enclosing codecs see the
      // whole region as read.
      return (extensions, bytes.length);
    },
  );
}

/// Codec for the extensions of a `Mint` or `Token` account.
Codec<Extensions, Extensions> getExtensionsCodec() {
  return combineCodec(getExtensionsEncoder(), getExtensionsDecoder());
}
