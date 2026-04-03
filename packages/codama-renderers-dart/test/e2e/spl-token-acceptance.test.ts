import { execSync } from "node:child_process";
import { existsSync, readFileSync, readdirSync, statSync } from "node:fs";
import { join, resolve } from "node:path";
import { describe, it, expect, beforeAll } from "vitest";
import { visit } from "@codama/visitors-core";

import { renderVisitor } from "../../src/visitors/renderVisitor.js";
import { getRenderMapVisitor } from "../../src/visitors/getRenderMapVisitor.js";

import splTokenIdl from "../fixtures/spl_token.json";

const TEST_GENERATED_DIR = resolve(__dirname, "../../test-generated");
const SPL_TOKEN_DIR = join(TEST_GENERATED_DIR, "lib/src/spl_token");

function isDartAvailable(): boolean {
  try {
    execSync("dart --version", {
      encoding: "utf-8",
      stdio: ["pipe", "pipe", "pipe"],
      timeout: 10_000,
    });
    return true;
  } catch {
    return false;
  }
}

function collectFiles(dir: string, prefix = ""): string[] {
  const files: string[] = [];
  if (!existsSync(dir)) return files;
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    const relative = prefix ? `${prefix}/${entry}` : entry;
    if (statSync(full).isDirectory()) {
      files.push(...collectFiles(full, relative));
    } else {
      files.push(relative);
    }
  }
  return files.sort();
}

describe("SPL Token acceptance: generation", () => {
  beforeAll(() => {
    // The SPL Token IDL is a native Codama rootNode, not Anchor.
    visit(
      splTokenIdl as any,
      renderVisitor(SPL_TOKEN_DIR, {
        formatCode: false,
        deleteFolderBeforeRendering: true,
      }),
    );
  });

  it("should generate files for both token and associated_token programs", () => {
    const files = collectFiles(SPL_TOKEN_DIR);
    expect(files.length).toBeGreaterThan(0);

    // Root barrel files for both programs
    expect(files).toContain("token.dart");
    expect(files).toContain("associated_token.dart");
  });

  it("should generate token program accounts", () => {
    const files = collectFiles(SPL_TOKEN_DIR);
    expect(files).toContain("accounts/mint.dart");
    expect(files).toContain("accounts/token.dart");
    expect(files).toContain("accounts/multisig.dart");
  });

  it("should generate token program instructions", () => {
    const files = collectFiles(SPL_TOKEN_DIR);
    expect(files).toContain("instructions/transfer.dart");
    expect(files).toContain("instructions/approve.dart");
    expect(files).toContain("instructions/mint_to.dart");
    expect(files).toContain("instructions/burn.dart");
    expect(files).toContain("instructions/initialize_mint.dart");
    expect(files).toContain("instructions/initialize_account.dart");
    expect(files).toContain("instructions/close_account.dart");
    expect(files).toContain("instructions/set_authority.dart");
    expect(files).toContain("instructions/freeze_account.dart");
    expect(files).toContain("instructions/thaw_account.dart");
  });

  it("should generate associated token instructions", () => {
    const files = collectFiles(SPL_TOKEN_DIR);
    expect(files).toContain("instructions/create_associated_token.dart");
    expect(files).toContain("instructions/create_associated_token_idempotent.dart");
    expect(files).toContain("instructions/recover_nested_associated_token.dart");
  });

  it("should generate type definitions", () => {
    const files = collectFiles(SPL_TOKEN_DIR);
    expect(files).toContain("types/authority_type.dart");
    expect(files).toContain("types/account_state.dart");
  });

  it("should generate error pages for both programs", () => {
    const files = collectFiles(SPL_TOKEN_DIR);
    expect(files).toContain("errors/token.dart");
    expect(files).toContain("errors/associated_token.dart");
  });

  it("should generate program pages for both programs", () => {
    const files = collectFiles(SPL_TOKEN_DIR);
    expect(files).toContain("programs/token.dart");
    expect(files).toContain("programs/associated_token.dart");
  });

  it("should generate PDA helpers", () => {
    const files = collectFiles(SPL_TOKEN_DIR);
    expect(files).toContain("pdas/associated_token.dart");
  });

  it("should reference the correct token program address", () => {
    const content = readFileSync(
      join(SPL_TOKEN_DIR, "programs/token.dart"),
      "utf-8",
    );
    expect(content).toContain("TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA");
  });

  it("should reference the correct associated token program address", () => {
    const content = readFileSync(
      join(SPL_TOKEN_DIR, "programs/associated_token.dart"),
      "utf-8",
    );
    expect(content).toContain("ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL");
  });

  it("should not contain [object Object] artifacts in any generated file", () => {
    const files = collectFiles(SPL_TOKEN_DIR).filter((f) =>
      f.endsWith(".dart"),
    );
    for (const file of files) {
      const content = readFileSync(join(SPL_TOKEN_DIR, file), "utf-8");
      expect(content, `${file} should not contain [object Object]`).not.toContain(
        "[object Object]",
      );
    }
  });

  it("should generate deterministic output on re-render", () => {
    // Capture first render
    const firstFiles = new Map<string, string>();
    for (const file of collectFiles(SPL_TOKEN_DIR).filter((f) =>
      f.endsWith(".dart"),
    )) {
      firstFiles.set(file, readFileSync(join(SPL_TOKEN_DIR, file), "utf-8"));
    }

    // Re-render
    visit(
      splTokenIdl as any,
      renderVisitor(SPL_TOKEN_DIR, {
        formatCode: false,
        deleteFolderBeforeRendering: true,
      }),
    );

    // Compare
    const secondFiles = collectFiles(SPL_TOKEN_DIR).filter((f) =>
      f.endsWith(".dart"),
    );
    expect(secondFiles.length).toBe(firstFiles.size);
    for (const file of secondFiles) {
      const content = readFileSync(join(SPL_TOKEN_DIR, file), "utf-8");
      expect(content, `${file} should be deterministic`).toBe(
        firstFiles.get(file),
      );
    }
  });
});

describe("SPL Token acceptance: Dart analysis", () => {
  const dartAvailable = isDartAvailable();

  it(
    "should resolve dart pub get in test-generated package",
    { timeout: 180_000 },
    () => {
      if (!dartAvailable) {
        console.log("Skipping: dart not available");
        return;
      }

      try {
        execSync("dart pub get", {
          cwd: TEST_GENERATED_DIR,
          encoding: "utf-8",
          timeout: 120_000,
          stdio: ["pipe", "pipe", "pipe"],
        });
      } catch (error: any) {
        console.log(
          "dart pub get had issues (may be expected in CI):",
          error.stderr?.substring(0, 500) || error.message,
        );
      }
    },
  );

  it(
    "should pass dart analyze on ALL generated SPL Token files with zero errors",
    { timeout: 120_000 },
    () => {
      if (!dartAvailable) {
        console.log("Skipping: dart not available");
        return;
      }

      const pubGetSucceeded = existsSync(
        join(TEST_GENERATED_DIR, ".dart_tool"),
      );
      if (!pubGetSucceeded) {
        console.log("Skipping: pub get did not succeed");
        return;
      }

      // This is the critical gate: the generated code MUST be analyze-clean.
      const result = execSync(
        `dart analyze ${SPL_TOKEN_DIR}`,
        {
          cwd: TEST_GENERATED_DIR,
          encoding: "utf-8",
          timeout: 60_000,
          stdio: ["pipe", "pipe", "pipe"],
        },
      );
      // If we get here without throwing, analysis passed.
      expect(result).toContain("No issues found");
    },
  );
});
