import type { Fragment } from "./fragment.js";
import { fragment, fragmentFromString, use } from "./fragment.js";

export interface ExactDecoderFragmentOptions {
  readonly typeName: string;
  readonly description: string;
  readonly discriminatorValidation: Fragment;
  readonly fromMapFields: string;
}

/**
 * Wrap a generated top-level struct decoder so it must consume all input.
 *
 * The wrapper preserves fixed/variable decoder metadata so it remains
 * compatible with the matching generated encoder when combined into a codec.
 */
export function getExactDecoderFragment({
  typeName,
  description,
  discriminatorValidation,
  fromMapFields,
}: ExactDecoderFragmentOptions): Fragment {
  const validation = discriminatorValidation.content
    ? `    ${discriminatorValidation.content.replaceAll("\n", "\n    ")}\n`
    : "";

  const result = fragment`  Never throwInvalidByteLength(int expected, int bytesLength) {
    throw ${use("SolanaError", "solanaErrors")}(
      ${use("SolanaErrorCode", "solanaErrors")}.codecsInvalidByteLength,
      {
        'codecDescription': '${fragmentFromString(description)}',
        'expected': expected,
        'bytesLength': bytesLength,
      },
    );
  }

  (${fragmentFromString(typeName)}, int) readExact(Uint8List bytes, int offset) {
${fragmentFromString(validation)}    final (map, newOffset) = structDecoder.read(bytes, offset);
    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }
    return (
      ${fragmentFromString(typeName)}(
${fragmentFromString(fromMapFields)}
      ),
      newOffset,
    );
  }

  return switch (structDecoder) {
    ${use("FixedSizeDecoder", "solanaCodecsCore")}<Map<String, Object?>>() =>
      ${use("FixedSizeDecoder", "solanaCodecsCore")}<${fragmentFromString(typeName)}>(
        fixedSize: structDecoder.fixedSize,
        read: (bytes, offset) {
          final bytesLength = bytes.length - offset;
          if (bytesLength != structDecoder.fixedSize) {
            throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
          }
          return readExact(bytes, offset);
        },
      ),
    ${use("VariableSizeDecoder", "solanaCodecsCore")}<Map<String, Object?>>() =>
      ${use("VariableSizeDecoder", "solanaCodecsCore")}<${fragmentFromString(typeName)}>(
        read: readExact,
        maxSize: structDecoder.maxSize,
      ),
  };`;
  result.imports.mergeWith(discriminatorValidation.imports);
  return result;
}
