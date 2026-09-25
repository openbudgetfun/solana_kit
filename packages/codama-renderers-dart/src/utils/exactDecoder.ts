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
      {
        'codecDescription': '${fragmentFromString(description)}',
  }

  }

  return switch (structDecoder) {
    ${use("FixedSizeDecoder", "solanaCodecsCore")}<Map<String, Object?>>() =>
          }
          return readTopLevel(bytes, offset);
  };`;
  result.imports.mergeWith(discriminatorValidation.imports);

  return result;
}
