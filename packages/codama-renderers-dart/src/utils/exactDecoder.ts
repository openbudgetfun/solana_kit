import type { Fragment } from "./fragment.js";
import { fragment, fragmentFromString, use } from "./fragment.js";

export interface TopLevelDecoderFragmentOptions {
  readonly typeName: string;
  readonly description: string;
  readonly discriminatorValidation: Fragment;
  readonly fromMapFields: string;
  readonly requireExactConsumption: boolean;
}

/**
 * Wrap a generated top-level struct decoder with discriminator and length
 * validation.
 *
 * The wrapper preserves fixed/variable decoder metadata so it remains
 * compatible with the matching generated encoder when combined into a codec.
 */
export function getTopLevelDecoderFragment({
  typeName,
  description,
  discriminatorValidation,
  fromMapFields,
  requireExactConsumption,
}: TopLevelDecoderFragmentOptions): Fragment {
  const validation = discriminatorValidation.content
    ? `    ${discriminatorValidation.content.replaceAll("\n", "\n    ")}\n`
    : "";

  const consumptionCheck = requireExactConsumption
    ? `    if (newOffset != bytes.length) {
      throwInvalidByteLength(newOffset - offset, bytes.length - offset);
    }
`
    : "";
  const fixedSizeCheck = requireExactConsumption
    ? "bytesLength != structDecoder.fixedSize"
    : "bytesLength < structDecoder.fixedSize";

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

  (${fragmentFromString(typeName)}, int) readTopLevel(Uint8List bytes, int offset) {
${fragmentFromString(validation)}    final (map, newOffset) = structDecoder.read(bytes, offset);
${fragmentFromString(consumptionCheck)}
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
          if (${fragmentFromString(fixedSizeCheck)}) {
            throwInvalidByteLength(structDecoder.fixedSize, bytesLength);
          }
          return readTopLevel(bytes, offset);
        },
      ),
    ${use("VariableSizeDecoder", "solanaCodecsCore")}<Map<String, Object?>>() =>
      ${use("VariableSizeDecoder", "solanaCodecsCore")}<${fragmentFromString(typeName)}>(
        read: readTopLevel,
        maxSize: structDecoder.maxSize,
      ),
  };`;
  result.imports.mergeWith(discriminatorValidation.imports);
  return result;
}
