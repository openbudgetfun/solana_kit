import { describe, it, expect } from "vitest";
import { visit } from "@codama/visitors-core";
import { getRenderMapVisitor as getJsRenderMapVisitor } from "@codama/renderers-js";

import { getRenderMapVisitor as getDartRenderMapVisitor } from "../../src/visitors/getRenderMapVisitor.js";

import splTokenIdl from "../fixtures/spl_token.json";

function normalizeFilePath(path: string): string {
  return path
    .replace(/\.(ts|dart)$/, "")
    .replace(/([A-Z])/g, (m) => `_${m.toLowerCase()}`)
    .replace(/^_/, "")
    .replace(/__/g, "_");
}

function categorizeKeys(keys: string[]): Record<string, string[]> {
  const categories: Record<string, string[]> = {
    accounts: [],
    instructions: [],
    types: [],
    errors: [],
    programs: [],
    pdas: [],
    barrel: [],
  };

  for (const key of keys) {
    if (
      key.endsWith("index.ts") ||
      key.endsWith("index.dart") ||
      key.match(/^[^/]+\.(ts|dart)$/) ||
      (key.match(/^[^/]+\/[^/]+\.(ts|dart)$/) &&
        (key.includes("/accounts.dart") ||
          key.includes("/instructions.dart") ||
          key.includes("/types.dart") ||
          key.includes("/errors.dart") ||
          key.includes("/programs.dart") ||
          key.includes("/pdas.dart")))
    ) {
      categories.barrel.push(key);
      continue;
    }

    if (key.startsWith("accounts/")) categories.accounts.push(key);
    else if (key.startsWith("instructions/"))
      categories.instructions.push(key);
    else if (key.startsWith("types/")) categories.types.push(key);
    else if (key.startsWith("errors/")) categories.errors.push(key);
    else if (key.startsWith("programs/")) categories.programs.push(key);
    else if (key.startsWith("pdas/")) categories.pdas.push(key);
  }

  return categories;
}

function extractProgramAddress(content: string): string | null {
  const dartMatch = content.match(/Address\('([A-Za-z0-9]+)'\)/);
  if (dartMatch) return dartMatch[1];
  const tsAsAddressMatch = content.match(
    /['"]([A-Za-z0-9]{32,50})['"]\s+as\s+Address/,
  );
  if (tsAsAddressMatch) return tsAsAddressMatch[1];
  const tsMatch = content.match(/address\s*\(\s*['"]([A-Za-z0-9]+)['"]\s*\)/);
  if (tsMatch) return tsMatch[1];
  return null;
}

function extractErrorCodes(content: string): number[] {
  const codes: number[] = [];
  const hexRegex = /0x([0-9a-fA-F]+)/g;
  let match;
  while ((match = hexRegex.exec(content)) !== null) {
    codes.push(parseInt(match[1], 16));
  }
  return [...new Set(codes)].sort((a, b) => a - b);
}

describe("SPL Token: JS vs Dart structural parity", () => {
  // The SPL Token IDL is a native Codama rootNode (not Anchor).
  const dartRenderMap = visit(splTokenIdl as any, getDartRenderMapVisitor());
  const jsRenderMap = visit(splTokenIdl as any, getJsRenderMapVisitor());

  const dartKeys = [...dartRenderMap.keys()].sort();
  const jsKeys = [...jsRenderMap.keys()].sort();

  const dartCategories = categorizeKeys(dartKeys);
  const jsCategories = categorizeKeys(jsKeys);

  it("should produce the same set of entity categories", () => {
    const dartNonEmpty = Object.entries(dartCategories)
      .filter(([k, v]) => k !== "barrel" && v.length > 0)
      .map(([k]) => k)
      .sort();
    const jsNonEmpty = Object.entries(jsCategories)
      .filter(([k, v]) => k !== "barrel" && v.length > 0)
      .map(([k]) => k)
      .sort();
    expect(dartNonEmpty).toEqual(jsNonEmpty);
  });

  it("should generate the same number of account files", () => {
    expect(dartCategories.accounts.length).toBe(
      jsCategories.accounts.length,
    );
  });

  it("should generate the same number of instruction files", () => {
    expect(dartCategories.instructions.length).toBe(
      jsCategories.instructions.length,
    );
  });

  it("should generate the same number of type files", () => {
    expect(dartCategories.types.length).toBe(jsCategories.types.length);
  });

  it("should generate the same number of error files", () => {
    expect(dartCategories.errors.length).toBe(jsCategories.errors.length);
  });

  it("should generate the same number of program files", () => {
    expect(dartCategories.programs.length).toBe(
      jsCategories.programs.length,
    );
  });

  it("should generate matching account entity names", () => {
    const dartNames = dartCategories.accounts
      .map((k) => normalizeFilePath(k))
      .sort();
    const jsNames = jsCategories.accounts
      .map((k) => normalizeFilePath(k))
      .sort();
    expect(dartNames).toEqual(jsNames);
  });

  it("should generate matching instruction entity names", () => {
    const dartNames = dartCategories.instructions
      .map((k) => normalizeFilePath(k))
      .sort();
    const jsNames = jsCategories.instructions
      .map((k) => normalizeFilePath(k))
      .sort();
    expect(dartNames).toEqual(jsNames);
  });

  it("should generate matching type entity names", () => {
    const dartNames = dartCategories.types
      .map((k) => normalizeFilePath(k))
      .sort();
    const jsNames = jsCategories.types
      .map((k) => normalizeFilePath(k))
      .sort();
    expect(dartNames).toEqual(jsNames);
  });

  it("should reference matching token program address", () => {
    const dartProgramFile = dartCategories.programs.find((k) =>
      k.includes("token") && !k.includes("associated"),
    )!;
    const jsProgramFile = jsCategories.programs.find((k) =>
      k.includes("token") && !k.includes("associated"),
    )!;

    const dartAddr = extractProgramAddress(
      dartRenderMap.get(dartProgramFile)!.content,
    );
    const jsAddr = extractProgramAddress(
      jsRenderMap.get(jsProgramFile)!.content,
    );
    expect(dartAddr).toBeTruthy();
    expect(dartAddr).toBe(jsAddr);
  });

  it("should reference matching associated token program address", () => {
    const dartProgramFile = dartCategories.programs.find((k) =>
      k.includes("associated"),
    )!;
    const jsProgramFile = jsCategories.programs.find((k) =>
      k.includes("associated"),
    )!;

    const dartAddr = extractProgramAddress(
      dartRenderMap.get(dartProgramFile)!.content,
    );
    const jsAddr = extractProgramAddress(
      jsRenderMap.get(jsProgramFile)!.content,
    );
    expect(dartAddr).toBeTruthy();
    expect(dartAddr).toBe(jsAddr);
  });

  it("should have matching token error codes", () => {
    const dartErrorFile = dartCategories.errors.find((k) =>
      k.includes("token") && !k.includes("associated"),
    )!;
    const jsErrorFile = jsCategories.errors.find((k) =>
      k.includes("token") && !k.includes("associated"),
    )!;

    const dartCodes = extractErrorCodes(
      dartRenderMap.get(dartErrorFile)!.content,
    );
    const jsCodes = extractErrorCodes(
      jsRenderMap.get(jsErrorFile)!.content,
    );
    expect(dartCodes).toEqual(jsCodes);
  });

  it("should have matching encoder/decoder patterns for accounts", () => {
    for (const dartKey of dartCategories.accounts) {
      const dartFrag = dartRenderMap.get(dartKey);
      expect(dartFrag, `Missing Dart fragment for ${dartKey}`).toBeDefined();

      const normalizedDart = normalizeFilePath(dartKey);
      const jsKey = jsCategories.accounts.find(
        (k) => normalizeFilePath(k) === normalizedDart,
      );
      expect(jsKey, `Missing JS key matching ${dartKey}`).toBeDefined();

      const jsFrag = jsRenderMap.get(jsKey!);
      expect(jsFrag, `Missing JS fragment for ${jsKey}`).toBeDefined();

      expect(dartFrag!.content).toContain("Encoder");
      expect(dartFrag!.content).toContain("Decoder");
      expect(dartFrag!.content).toContain("Codec");
      expect(jsFrag!.content).toContain("Encoder");
      expect(jsFrag!.content).toContain("Decoder");
      expect(jsFrag!.content).toContain("Codec");
    }
  });

  it("should generate matching Mint account fields", () => {
    const dartContent = dartRenderMap.get("accounts/mint.dart")!.content;
    const jsContent = jsRenderMap.get("accounts/mint.ts")!.content;

    const fields = [
      "mintAuthority",
      "supply",
      "decimals",
      "isInitialized",
      "freezeAuthority",
    ];
    for (const field of fields) {
      expect(dartContent, `Dart Mint should have '${field}'`).toContain(
        field,
      );
      expect(jsContent, `JS Mint should have '${field}'`).toContain(field);
    }
  });

  it("should generate matching Token account fields", () => {
    const dartContent = dartRenderMap.get("accounts/token.dart")!.content;
    const jsContent = jsRenderMap.get("accounts/token.ts")!.content;

    const fields = ["mint", "owner", "amount", "delegate", "state"];
    for (const field of fields) {
      expect(dartContent, `Dart Token should have '${field}'`).toContain(
        field,
      );
      expect(jsContent, `JS Token should have '${field}'`).toContain(field);
    }
  });
});
