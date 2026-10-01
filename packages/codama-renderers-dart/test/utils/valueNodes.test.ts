import {
  booleanValueNode,
  bytesValueNode,
  noneValueNode,
  numberValueNode,
  publicKeyValueNode,
  stringValueNode,
} from "@codama/nodes";
import { describe, expect, it } from "vitest";

import {
  getDartValueFragment,
  isConstDartValueNode,
} from "../../src/utils/valueNodes.js";

describe("getDartValueFragment", () => {
  it("escapes Dart interpolation and control characters", () => {
    const fragment = getDartValueFragment(
      stringValueNode("it's $unsafe\nnext\\line"),
    );

    expect(fragment.content).toBe("'it\\'s \\$unsafe\\nnext\\\\line'");
  });

  it("renders base16 bytes", () => {
    const fragment = getDartValueFragment(bytesValueNode("base16", "aabb"));

    expect(fragment.content).toBe("Uint8List.fromList([0xaa, 0xbb])");
  });

  it("renders deterministic primitive values", () => {
    expect(getDartValueFragment(numberValueNode(3), "BigInt").content).toBe(
      "BigInt.from(3)",
    );
    expect(getDartValueFragment(booleanValueNode(true)).content).toBe("true");
    expect(getDartValueFragment(noneValueNode()).content).toBe("null");
    expect(getDartValueFragment(bytesValueNode("base16", "")).content).toBe(
      "Uint8List.fromList([])",
    );
  });

  it("renders known and unknown public keys", () => {
    expect(
      getDartValueFragment(
        publicKeyValueNode("11111111111111111111111111111111"),
      ).content,
    ).toBe("systemProgramAddress");
    expect(
      getDartValueFragment(publicKeyValueNode("Unknown111111111111111111111111"))
        .content,
    ).toBe("Address('Unknown111111111111111111111111')");
  });

  it("identifies values that are valid in const initializers", () => {
    expect(isConstDartValueNode(numberValueNode(1))).toBe(true);
    expect(isConstDartValueNode(booleanValueNode(false))).toBe(true);
    expect(isConstDartValueNode(stringValueNode("value"))).toBe(true);
    expect(isConstDartValueNode(noneValueNode())).toBe(true);
    expect(
      isConstDartValueNode(
        publicKeyValueNode("11111111111111111111111111111111"),
      ),
    ).toBe(true);
    expect(isConstDartValueNode(bytesValueNode("base16", "00"))).toBe(false);
  });

  it("rejects bytes encodings that cannot be rendered deterministically", () => {
    expect(() =>
      getDartValueFragment(bytesValueNode("base64", "qrs="))
    ).toThrow(/Unsupported deterministic bytes encoding: base64/);
  });

  it("rejects malformed base16 bytes", () => {
    expect(() =>
      getDartValueFragment(bytesValueNode("base16", "abc"))
    ).toThrow(/Invalid hexadecimal bytes value/);
  });

  it("rejects contextual values without silently guessing", () => {
    const contextualValue = { kind: "resolverValueNode" } as never;

    expect(() => getDartValueFragment(contextualValue)).toThrow(
      /Unsupported deterministic Dart value node: resolverValueNode/,
    );
  });
});
