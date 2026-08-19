import type {
  InstructionInputValueNode,
  ValueNode,
} from "@codama/nodes";

import type { Fragment } from "./fragment.js";
import { fragment, fragmentFromString, use } from "./fragment.js";
import { WELL_KNOWN_ADDRESSES } from "./wellKnownAddresses.js";

type RenderableValueNode = InstructionInputValueNode | ValueNode;

/**
 * Render a standalone Codama value as a Dart expression.
 *
 * Contextual instruction values need resolver state and are deliberately
 * rejected here. Defaults and discriminators must be deterministic at code
 * generation time so generated encoders cannot silently choose a different
 * wire value.
 */
export function getDartValueFragment(
  value: RenderableValueNode,
  dartType?: string,
): Fragment {
  switch (value.kind) {
    case "numberValueNode":
      return fragmentFromString(
        dartType === "BigInt"
          ? `BigInt.from(${value.number})`
          : String(value.number),
      );
    case "booleanValueNode":
      return fragmentFromString(String(value.boolean));
    case "stringValueNode":
      return fragmentFromString(toDartStringLiteral(value.string));
    case "noneValueNode":
      return fragmentFromString("null");
    case "bytesValueNode": {
      if (value.encoding !== "base16") {
        throw new Error(
          `Unsupported deterministic bytes encoding: ${value.encoding}`,
        );
      }
      const clean = value.data.replace(/^0x/, "");
      if (clean.length % 2 !== 0 || !/^[0-9a-f]*$/i.test(clean)) {
        throw new Error(`Invalid hexadecimal bytes value: ${value.data}`);
      }
      const bytes = clean.match(/.{2}/g)?.map((byte) => `0x${byte}`) ?? [];
      return fragment`${use("Uint8List", "dartTypedData")}.fromList([${fragmentFromString(bytes.join(", "))}])`;
    }
    case "publicKeyValueNode": {
      const wellKnownName = WELL_KNOWN_ADDRESSES.get(value.publicKey);
      return wellKnownName
        ? fragment`${use(wellKnownName, "solanaAddresses")}`
        : fragment`${use("Address", "solanaAddresses")}(${fragmentFromString(toDartStringLiteral(value.publicKey))})`;
    }
    default:
      throw new Error(
        `Unsupported deterministic Dart value node: ${value.kind}`,
      );
  }
}

/** Return whether a rendered standalone value is valid in a const initializer. */
export function isConstDartValueNode(value: RenderableValueNode): boolean {
  switch (value.kind) {
    case "numberValueNode":
    case "booleanValueNode":
    case "stringValueNode":
    case "noneValueNode":
    case "publicKeyValueNode":
      return true;
    default:
      return false;
  }
}

function toDartStringLiteral(value: string): string {
  return `'${value
    .replaceAll("\\", "\\\\")
    .replaceAll("\n", "\\n")
    .replaceAll("\r", "\\r")
    .replaceAll("\t", "\\t")
    .replaceAll("\b", "\\b")
    .replaceAll("\f", "\\f")
    .replaceAll("$", "\\$")
    .replaceAll("'", "\\'")}'`;
}
