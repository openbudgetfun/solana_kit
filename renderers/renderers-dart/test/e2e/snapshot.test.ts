import { existsSync, mkdirSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { visit } from "@codama/visitors-core";
import { rootNodeFromAnchor } from "@codama/nodes-from-anchor";

import { renderVisitor } from "../../src/visitors/renderVisitor.js";

import tokenVaultIdl from "../fixtures/token_vault.json";
import stakingIdl from "../fixtures/staking.json";

/**
 * Load and convert an Anchor IDL JSON to a Codama root node.
 */
function loadIdl(idl: any) {
  return rootNodeFromAnchor(idl);
}

/**
 * Recursively collect all file paths under a directory.
 */
function collectFiles(dir: string, prefix = ""): string[] {
  const fs = require("node:fs");
  const path = require("node:path");
  const files: string[] = [];
  for (const entry of fs.readdirSync(dir)) {
    const full = path.join(dir, entry);
    const relative = prefix ? `${prefix}/${entry}` : entry;
    if (fs.statSync(full).isDirectory()) {
      files.push(...collectFiles(full, relative));
    } else {
      files.push(relative);
    }
  }
  return files.sort();
}

describe("Snapshot: Token Vault", () => {
  let outputDir: string;

  beforeAll(() => {
    outputDir = join(
      tmpdir(),
      `codama-dart-snapshot-vault-${Date.now()}-${Math.random().toString(36).slice(2)}`,
    );
    mkdirSync(outputDir, { recursive: true });
    const root = loadIdl(tokenVaultIdl);
    visit(root, renderVisitor(outputDir, { formatCode: false }));
  });

  afterAll(() => {
    if (existsSync(outputDir)) {
      rmSync(outputDir, { recursive: true, force: true });
    }
  });

  it("should produce the expected file list", () => {
    const files = collectFiles(outputDir);
    expect(files).toMatchSnapshot();
  });

  it("should match snapshot for token_vault.dart (root barrel)", () => {
    const content = readFileSync(join(outputDir, "token_vault.dart"), "utf-8");
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for accounts/accounts.dart (barrel)", () => {
    const content = readFileSync(
      join(outputDir, "accounts/accounts.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for accounts/vault.dart", () => {
    const content = readFileSync(
      join(outputDir, "accounts/vault.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for accounts/deposit_record.dart", () => {
    const content = readFileSync(
      join(outputDir, "accounts/deposit_record.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for instructions/instructions.dart (barrel)", () => {
    const content = readFileSync(
      join(outputDir, "instructions/instructions.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for instructions/initialize_vault.dart", () => {
    const content = readFileSync(
      join(outputDir, "instructions/initialize_vault.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for instructions/deposit.dart", () => {
    const content = readFileSync(
      join(outputDir, "instructions/deposit.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for instructions/withdraw.dart", () => {
    const content = readFileSync(
      join(outputDir, "instructions/withdraw.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for instructions/update_vault_status.dart", () => {
    const content = readFileSync(
      join(outputDir, "instructions/update_vault_status.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for types/types.dart (barrel)", () => {
    const content = readFileSync(
      join(outputDir, "types/types.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for types/vault_status.dart", () => {
    const content = readFileSync(
      join(outputDir, "types/vault_status.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for types/vault_config.dart", () => {
    const content = readFileSync(
      join(outputDir, "types/vault_config.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for errors/errors.dart (barrel)", () => {
    const content = readFileSync(
      join(outputDir, "errors/errors.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for errors/token_vault.dart", () => {
    const content = readFileSync(
      join(outputDir, "errors/token_vault.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for programs/programs.dart (barrel)", () => {
    const content = readFileSync(
      join(outputDir, "programs/programs.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for programs/token_vault.dart", () => {
    const content = readFileSync(
      join(outputDir, "programs/token_vault.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });
});

describe("Snapshot: Staking", () => {
  let outputDir: string;

  beforeAll(() => {
    outputDir = join(
      tmpdir(),
      `codama-dart-snapshot-staking-${Date.now()}-${Math.random().toString(36).slice(2)}`,
    );
    mkdirSync(outputDir, { recursive: true });
    const root = loadIdl(stakingIdl);
    visit(root, renderVisitor(outputDir, { formatCode: false }));
  });

  afterAll(() => {
    if (existsSync(outputDir)) {
      rmSync(outputDir, { recursive: true, force: true });
    }
  });

  it("should produce the expected file list", () => {
    const files = collectFiles(outputDir);
    expect(files).toMatchSnapshot();
  });

  it("should match snapshot for staking.dart (root barrel)", () => {
    const content = readFileSync(join(outputDir, "staking.dart"), "utf-8");
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for accounts/accounts.dart (barrel)", () => {
    const content = readFileSync(
      join(outputDir, "accounts/accounts.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for accounts/stake_pool.dart", () => {
    const content = readFileSync(
      join(outputDir, "accounts/stake_pool.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for accounts/stake_account.dart", () => {
    const content = readFileSync(
      join(outputDir, "accounts/stake_account.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for instructions/instructions.dart (barrel)", () => {
    const content = readFileSync(
      join(outputDir, "instructions/instructions.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for instructions/initialize_pool.dart", () => {
    const content = readFileSync(
      join(outputDir, "instructions/initialize_pool.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for instructions/stake.dart", () => {
    const content = readFileSync(
      join(outputDir, "instructions/stake.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for instructions/unstake.dart", () => {
    const content = readFileSync(
      join(outputDir, "instructions/unstake.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for instructions/claim_rewards.dart", () => {
    const content = readFileSync(
      join(outputDir, "instructions/claim_rewards.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for types/types.dart (barrel)", () => {
    const content = readFileSync(
      join(outputDir, "types/types.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for types/pool_status.dart", () => {
    const content = readFileSync(
      join(outputDir, "types/pool_status.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for types/stake_info.dart", () => {
    const content = readFileSync(
      join(outputDir, "types/stake_info.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for errors/errors.dart (barrel)", () => {
    const content = readFileSync(
      join(outputDir, "errors/errors.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for errors/staking.dart", () => {
    const content = readFileSync(
      join(outputDir, "errors/staking.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for programs/programs.dart (barrel)", () => {
    const content = readFileSync(
      join(outputDir, "programs/programs.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });

  it("should match snapshot for programs/staking.dart", () => {
    const content = readFileSync(
      join(outputDir, "programs/staking.dart"),
      "utf-8",
    );
    expect(content).toMatchSnapshot();
  });
});
