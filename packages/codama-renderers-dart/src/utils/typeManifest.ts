import type { Fragment } from "./fragment.js";
import { emptyFragment } from "./fragment.js";

/**
 * Represents how a Codama type maps to Dart types and codec expressions.
 */
export interface TypeManifest {
  /** The Dart type name (e.g. `int`, `BigInt`, `Address`, `MyStruct`). */
  type: Fragment;
  /** The Dart encoder expression (e.g. `getU8Encoder()`). */
  encoder: Fragment;
  /** The Dart decoder expression (e.g. `getU8Decoder()`). */
  decoder: Fragment;
  /** The Dart value expression for default values. */
  value: Fragment;
  /** Whether this is a scalar enum (Dart `enum`). */
  isEnum: boolean;
}

/**
 * Create an empty TypeManifest.
 */
export function emptyTypeManifest(): TypeManifest {
  return {
    type: emptyFragment(),
    encoder: emptyFragment(),
    decoder: emptyFragment(),
    value: emptyFragment(),
    isEnum: false,
  };
}
