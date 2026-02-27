import { describe, it, expect } from "vitest";
import { visit } from "@codama/visitors-core";
import { rootNodeFromAnchor } from "@codama/nodes-from-anchor";
import { getRenderMapVisitor as getJsRenderMapVisitor } from "@codama/renderers-js";

import { getRenderMapVisitor as getDartRenderMapVisitor } from "../../src/visitors/getRenderMapVisitor.js";

import tokenVaultIdl from "../fixtures/token_vault.json";
import stakingIdl from "../fixtures/staking.json";

/**
 * Helper to categorize render map keys into entity categories.
 * JS uses camelCase .ts files, Dart uses snake_case .dart files.
 */
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
    // Skip barrel/index files
    if (
      key.endsWith("index.ts") ||
      key.endsWith("index.dart") ||
      key.match(/^[^/]+\.(ts|dart)$/) || // Root barrel (e.g. token_vault.dart, index.ts)
      key.match(/^[^/]+\/[^/]+\.(ts|dart)$/) &&
        (key.includes("/accounts.dart") ||
          key.includes("/instructions.dart") ||
          key.includes("/types.dart") ||
          key.includes("/errors.dart") ||
          key.includes("/programs.dart") ||
          key.includes("/pdas.dart"))
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

/**
 * Extract class/type names from Dart content.
 * Matches: class Foo {, enum Foo {, sealed class Foo {, typedef Foo =
 */
function extractDartTypeNames(content: string): string[] {
  const names: string[] = [];
  const classRegex =
    /(?:sealed\s+)?class\s+([A-Z][A-Za-z0-9]*)|enum\s+([A-Z][A-Za-z0-9]*)|typedef\s+([A-Z][A-Za-z0-9]*)/g;
  let match;
  while ((match = classRegex.exec(content)) !== null) {
    names.push(match[1] || match[2] || match[3]);
  }
  return names;
}

/**
 * Extract type/interface names from TypeScript content.
 * Matches: type Foo =, export type Foo =, type Foo<, export interface
 */
function extractTsTypeNames(content: string): string[] {
  const names: string[] = [];
  const typeRegex =
    /(?:export\s+)?type\s+([A-Z][A-Za-z0-9]*)|(?:export\s+)?interface\s+([A-Z][A-Za-z0-9]*)/g;
  let match;
  while ((match = typeRegex.exec(content)) !== null) {
    names.push(match[1] || match[2]);
  }
  return names;
}

/**
 * Extract function names from Dart content.
 * Matches top-level function declarations.
 */
function extractDartFunctionNames(content: string): string[] {
  const names: string[] = [];
  const fnRegex =
    /^(?:Encoder|Decoder|Codec|Account|Instruction|String\?|bool|Future)\S*\s+([a-z][A-Za-z0-9]*)\s*[(<]/gm;
  let match;
  while ((match = fnRegex.exec(content)) !== null) {
    names.push(match[1]);
  }
  return names;
}

/**
 * Extract function names from TypeScript content.
 * Matches: export function foo(, export async function foo(
 */
function extractTsFunctionNames(content: string): string[] {
  const names: string[] = [];
  const fnRegex =
    /export\s+(?:async\s+)?function\s+([a-z][A-Za-z0-9]*)/g;
  let match;
  while ((match = fnRegex.exec(content)) !== null) {
    names.push(match[1]);
  }
  return names;
}

/**
 * Extract error code values from content (both Dart and TS).
 */
function extractErrorCodes(content: string): number[] {
  const codes: number[] = [];
  // Match hex codes: 0x1770, 0x1771, etc.
  const hexRegex = /0x([0-9a-fA-F]+)/g;
  let match;
  while ((match = hexRegex.exec(content)) !== null) {
    codes.push(parseInt(match[1], 16));
  }
  return [...new Set(codes)].sort((a, b) => a - b);
}

/**
 * Extract program address from content.
 */
function extractProgramAddress(content: string): string | null {
  // Dart: Address('VauLT1111...')
  const dartMatch = content.match(/Address\('([A-Za-z0-9]+)'\)/);
  if (dartMatch) return dartMatch[1];

  // TS: 'VauLT1111...' as Address<'VauLT1111...'> or address("VauLT1111...")
  const tsAsAddressMatch = content.match(
    /['"]([A-Za-z0-9]{32,50})['"]\s+as\s+Address/,
  );
  if (tsAsAddressMatch) return tsAsAddressMatch[1];

  const tsMatch = content.match(/address\s*\(\s*['"]([A-Za-z0-9]+)['"]\s*\)/);
  if (tsMatch) return tsMatch[1];

  return null;
}

/**
 * Normalize a name by stripping common suffixes/prefixes and lowering.
 * This helps compare e.g. "getVaultEncoder" vs "getVaultEncoder".
 */
function normalizeFunctionName(name: string): string {
  return name.toLowerCase();
}

/**
 * Strip file extensions and normalize paths for comparison.
 * accounts/vault.dart -> accounts/vault
 * accounts/vault.ts -> accounts/vault
 */
function normalizeFilePath(path: string): string {
  return path
    .replace(/\.(ts|dart)$/, "")
    .replace(/([A-Z])/g, (m) => `_${m.toLowerCase()}`)
    .replace(/^_/, "")
    .replace(/__/g, "_");
}

describe("JS vs Dart structural comparison: Token Vault", () => {
  const root = rootNodeFromAnchor(tokenVaultIdl);
  const dartRenderMap = visit(root, getDartRenderMapVisitor());
  const jsRenderMap = visit(root, getJsRenderMapVisitor());

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

  it("should generate a program page in both renderers", () => {
    expect(dartCategories.programs.length).toBeGreaterThan(0);
    expect(jsCategories.programs.length).toBeGreaterThan(0);
    expect(dartCategories.programs.length).toBe(
      jsCategories.programs.length,
    );
  });

  it("should generate matching account entity names", () => {
    const dartAccountNames = dartCategories.accounts
      .map((k) => normalizeFilePath(k))
      .sort();
    const jsAccountNames = jsCategories.accounts
      .map((k) => normalizeFilePath(k))
      .sort();

    expect(dartAccountNames).toEqual(jsAccountNames);
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

  it("should have matching encoder/decoder/codec function names for accounts", () => {
    for (const dartKey of dartCategories.accounts) {
      const dartFrag = dartRenderMap.get(dartKey);
      expect(dartFrag, `Missing Dart fragment for ${dartKey}`).toBeDefined();

      // Find the matching JS key
      const normalizedDart = normalizeFilePath(dartKey);
      const jsKey = jsCategories.accounts.find(
        (k) => normalizeFilePath(k) === normalizedDart,
      );
      expect(jsKey, `Missing JS key matching ${dartKey}`).toBeDefined();

      const jsFrag = jsRenderMap.get(jsKey!);
      expect(jsFrag, `Missing JS fragment for ${jsKey}`).toBeDefined();

      const dartContent = dartFrag!.content;
      const jsContent = jsFrag!.content;

      // Both should have encoder functions
      expect(dartContent).toContain("Encoder");
      expect(jsContent).toContain("Encoder");

      // Both should have decoder functions
      expect(dartContent).toContain("Decoder");
      expect(jsContent).toContain("Decoder");

      // Both should have codec functions
      expect(dartContent).toContain("Codec");
      expect(jsContent).toContain("Codec");
    }
  });

  it("should reference the same program address in both renderers", () => {
    const dartProgramKey = dartCategories.programs[0];
    const jsProgramKey = jsCategories.programs[0];

    const dartContent = dartRenderMap.get(dartProgramKey)!.content;
    const jsContent = jsRenderMap.get(jsProgramKey)!.content;

    const dartAddress = extractProgramAddress(dartContent);
    const jsAddress = extractProgramAddress(jsContent);

    expect(dartAddress).toBeTruthy();
    expect(jsAddress).toBeTruthy();
    expect(dartAddress).toBe(jsAddress);
  });

  it("should have matching error codes", () => {
    const dartErrorKey = dartCategories.errors[0];
    const jsErrorKey = jsCategories.errors[0];

    const dartContent = dartRenderMap.get(dartErrorKey)!.content;
    const jsContent = jsRenderMap.get(jsErrorKey)!.content;

    const dartCodes = extractErrorCodes(dartContent);
    const jsCodes = extractErrorCodes(jsContent);

    // Both should have error codes 6000-6004
    expect(dartCodes).toEqual(jsCodes);
  });

  it("should generate struct fields with matching names for Vault account", () => {
    const dartContent = dartRenderMap.get("accounts/vault.dart")!.content;
    const jsContent = jsRenderMap.get("accounts/vault.ts")!.content;

    // Fields that should appear in both (field names from IDL)
    const expectedFields = [
      "authority",
      "tokenMint",
      "totalDeposited",
      "maxCapacity",
      "status",
      "createdAt",
      "bumpSeed",
    ];

    for (const field of expectedFields) {
      expect(
        dartContent,
        `Dart Vault should contain field '${field}'`,
      ).toContain(field);
      expect(
        jsContent,
        `JS Vault should contain field '${field}'`,
      ).toContain(field);
    }
  });
});

describe("JS vs Dart structural comparison: Staking", () => {
  const root = rootNodeFromAnchor(stakingIdl);
  const dartRenderMap = visit(root, getDartRenderMapVisitor());
  const jsRenderMap = visit(root, getJsRenderMapVisitor());

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

  it("should generate matching account entity names", () => {
    const dartAccountNames = dartCategories.accounts
      .map((k) => normalizeFilePath(k))
      .sort();
    const jsAccountNames = jsCategories.accounts
      .map((k) => normalizeFilePath(k))
      .sort();

    expect(dartAccountNames).toEqual(jsAccountNames);
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

  it("should reference the same program address in both renderers", () => {
    const dartProgramKey = dartCategories.programs[0];
    const jsProgramKey = jsCategories.programs[0];

    const dartContent = dartRenderMap.get(dartProgramKey)!.content;
    const jsContent = jsRenderMap.get(jsProgramKey)!.content;

    const dartAddress = extractProgramAddress(dartContent);
    const jsAddress = extractProgramAddress(jsContent);

    expect(dartAddress).toBeTruthy();
    expect(jsAddress).toBeTruthy();
    expect(dartAddress).toBe(jsAddress);
  });

  it("should have matching error codes", () => {
    const dartErrorKey = dartCategories.errors[0];
    const jsErrorKey = jsCategories.errors[0];

    const dartContent = dartRenderMap.get(dartErrorKey)!.content;
    const jsContent = jsRenderMap.get(jsErrorKey)!.content;

    const dartCodes = extractErrorCodes(dartContent);
    const jsCodes = extractErrorCodes(jsContent);

    expect(dartCodes).toEqual(jsCodes);
  });

  it("should generate struct fields with matching names for StakePool account", () => {
    const dartContent = dartRenderMap.get(
      "accounts/stake_pool.dart",
    )!.content;
    const jsContent = jsRenderMap.get("accounts/stakePool.ts")!.content;

    const expectedFields = [
      "admin",
      "rewardMint",
      "stakeMint",
      "totalStaked",
      "rewardRate",
      "minStakeDuration",
      "maxStakers",
      "currentStakers",
      "isActive",
      "bump",
    ];

    for (const field of expectedFields) {
      expect(
        dartContent,
        `Dart StakePool should contain field '${field}'`,
      ).toContain(field);
      expect(
        jsContent,
        `JS StakePool should contain field '${field}'`,
      ).toContain(field);
    }
  });

  it("should have matching encoder/decoder patterns for type files", () => {
    for (const dartKey of dartCategories.types) {
      const dartFrag = dartRenderMap.get(dartKey);
      expect(dartFrag).toBeDefined();

      const normalizedDart = normalizeFilePath(dartKey);
      const jsKey = jsCategories.types.find(
        (k) => normalizeFilePath(k) === normalizedDart,
      );
      expect(jsKey, `Missing JS key matching ${dartKey}`).toBeDefined();

      const jsFrag = jsRenderMap.get(jsKey!);
      expect(jsFrag).toBeDefined();

      // Both should contain encoder/decoder pattern
      expect(dartFrag!.content).toContain("Encoder");
      expect(jsFrag!.content).toContain("Encoder");
      expect(dartFrag!.content).toContain("Decoder");
      expect(jsFrag!.content).toContain("Decoder");
    }
  });

  it("should generate enum variants with matching names for PoolStatus", () => {
    const dartContent = dartRenderMap.get(
      "types/pool_status.dart",
    )!.content;
    const jsContent = jsRenderMap.get("types/poolStatus.ts")!.content;

    // Both should contain the enum variant names
    const variants = ["Uninitialized", "Active", "Paused", "Deprecated"];
    for (const v of variants) {
      // Case insensitive check since Dart uses camelCase and TS uses PascalCase for enum keys
      const vLower = v.toLowerCase();
      expect(dartContent.toLowerCase()).toContain(vLower);
      expect(jsContent.toLowerCase()).toContain(vLower);
    }
  });
});
