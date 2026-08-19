import { existsSync, mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { describe, expect, it } from "vitest";
import { visit } from "@codama/visitors-core";
import type { RootNode } from "@codama/nodes";

import { normalizeRootNode } from "../../src/utils/normalizeRootNode.js";
import { getRenderMapVisitor } from "../../src/visitors/getRenderMapVisitor.js";
import { renderVisitor } from "../../src/visitors/renderVisitor.js";

const fixtureNames = [
  "pina-omitted-additional-programs",
  "pina-omitted-account-fields",
  "pina-omitted-program-accounts",
  "pina-omitted-program-instructions",
  "pina-omitted-instruction-accounts",
  "pina-omitted-instruction-arguments",
] as const;

describe("Pina serialized IDLs", () => {
  it.each(fixtureNames)("renders %s with omitted empty collections", (fixtureName) => {
    const fixture = loadFixture(fixtureName);
    const outputDir = mkdtempSync(join(tmpdir(), "codama-dart-pina-"));

    try {
      visit(fixture, renderVisitor(outputDir, { formatCode: false }));

      const programName = fixture.program.name.replace(
        /([A-Z])/g,
        "_$1",
      ).replace(/^_/, "").toLowerCase();
      expect(existsSync(join(outputDir, `${programName}.dart`))).toBe(true);
    } finally {
      rmSync(outputDir, { recursive: true, force: true });
    }
  });

  it("keeps the raw parsed root unchanged while making it safe for map visitors", () => {
    const rootFixture = loadFixture("pina-omitted-additional-programs");
    const instructionFixture = loadFixture("pina-omitted-instruction-accounts");
    const normalizedRoot = normalizeRootNode(rootFixture);
    const normalizedInstruction = normalizeRootNode(instructionFixture);
    const renderMap = visit(normalizedInstruction, getRenderMapVisitor());

    expect(rootFixture.additionalPrograms).toBeUndefined();
    expect(rootFixture.program.accounts).toBeUndefined();
    expect(rootFixture.program.errors).toBeUndefined();
    expect(instructionFixture.program.instructions[0].accounts).toBeUndefined();
    expect(normalizedRoot.additionalPrograms).toEqual([]);
    expect(normalizedInstruction.program.instructions[0].accounts).toEqual([]);
    expect(renderMap.has("instructions/hello.dart")).toBe(true);
  });

  it("normalizes nested serialized child collections without mutating the source", () => {
    const rawRoot = {
      kind: "rootNode",
      program: {
        kind: "programNode",
        name: "pinaNestedCollections",
        publicKey: "11111111111111111111111111111111",
        version: "0.0.0",
        accounts: [
          {
            kind: "accountNode",
            name: "state",
            data: { kind: "structTypeNode" },
          },
        ],
        definedTypes: [
          {
            kind: "definedTypeNode",
            name: "stateKind",
            type: { kind: "enumTypeNode" },
          },
        ],
        instructions: [],
        pdas: [{ kind: "pdaNode", name: "statePda" }],
        errors: [],
        metadata: {
          tuple: { kind: "tupleTypeNode" },
          hiddenPrefix: { kind: "hiddenPrefixTypeNode" },
          hiddenSuffix: { kind: "hiddenSuffixTypeNode" },
        },
      },
    } as unknown as RootNode;

    const normalized = normalizeRootNode(rawRoot) as unknown as {
      program: {
        accounts: Array<{ data: { fields: unknown[] } }>;
        definedTypes: Array<{ type: { variants: unknown[] } }>;
        metadata: {
          tuple: { items: unknown[] };
          hiddenPrefix: { prefix: unknown[] };
          hiddenSuffix: { suffix: unknown[] };
        };
        pdas: Array<{ seeds: unknown[] }>;
      };
    };

    expect((rawRoot as unknown as { program: { pdas: Array<{ seeds?: unknown[] }> } }).program.pdas[0].seeds).toBeUndefined();
    expect(normalized.program.accounts[0].data.fields).toEqual([]);
    expect(normalized.program.definedTypes[0].type.variants).toEqual([]);
    expect(normalized.program.metadata.tuple.items).toEqual([]);
    expect(normalized.program.metadata.hiddenPrefix.prefix).toEqual([]);
    expect(normalized.program.metadata.hiddenSuffix.suffix).toEqual([]);
    expect(normalized.program.pdas[0].seeds).toEqual([]);
  });

  it("renders an account with omitted struct fields", () => {
    const fixture = loadFixture("pina-omitted-account-fields");
    const outputDir = mkdtempSync(join(tmpdir(), "codama-dart-pina-account-"));

    try {
      visit(fixture, renderVisitor(outputDir, { formatCode: false }));

      const account = readFileSync(join(outputDir, "accounts/state.dart"), "utf8");
      expect(account).toContain("class State {");
      expect(account).toContain("const State();");
    } finally {
      rmSync(outputDir, { recursive: true, force: true });
    }
  });
});

function loadFixture(name: (typeof fixtureNames)[number]) {
  return JSON.parse(
    readFileSync(join(import.meta.dirname, "../fixtures", `${name}.json`), "utf8"),
  );
}
