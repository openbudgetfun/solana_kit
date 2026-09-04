import { pdaNode, programNode, rootNode } from "@codama/nodes";
import { visit } from "@codama/visitors-core";
import { describe, expect, it } from "vitest";
import { getRenderMapVisitor } from "../src/visitors/getRenderMapVisitor.js";

function renderSeed(seed: NonNullable<Parameters<typeof pdaNode>[0]["seeds"]>[number]): string {
  return visit(rootNode(programNode({
    name: "safe",
    publicKey: "11111111111111111111111111111111",
    pdas: [pdaNode({ name: "seed", seeds: [seed] })],
  })), getRenderMapVisitor()).get("pdas/seed.dart")!.content;
}

describe("PDA constant value encoding", () => {
  it("passes a BigInt into a 64-bit seed encoder", () => {
    expect(renderSeed({
      kind: "constantPdaSeedNode",
      type: { kind: "numberTypeNode", format: "u64" },
      value: { kind: "numberValueNode", number: 42 },
    })).toContain("getU64Encoder().encode(BigInt.from(42))");
  });

  it.each(["0", "zz"])("rejects malformed hexadecimal seed %j", (data) => {
    expect(() => renderSeed({
      kind: "constantPdaSeedNode",
      type: { kind: "bytesTypeNode" },
      value: { kind: "bytesValueNode", encoding: "base16", data },
    })).toThrow(/Invalid hexadecimal/);
  });

  it("rejects bytes with an unsupported encoding instead of reinterpreting them as hex", () => {
    expect(() => renderSeed({
      kind: "constantPdaSeedNode",
      type: { kind: "bytesTypeNode" },
      value: { kind: "bytesValueNode", encoding: "base64", data: "AAAA" },
    })).toThrow(/Unsupported deterministic bytes encoding/);
  });
});
