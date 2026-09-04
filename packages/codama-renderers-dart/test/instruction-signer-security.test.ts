import { spawnSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import {
  booleanTypeNode,
  instructionAccountNode,
  instructionArgumentNode,
  instructionNode,
  programNode,
  rootNode,
  type InstructionNode,
} from "@codama/nodes";
import { visit } from "@codama/visitors-core";
import { afterEach, describe, expect, it } from "vitest";

import { renderVisitor } from "../src/visitors/renderVisitor.js";

const directories: string[] = [];
const packageConfig = resolve(__dirname, "../../../.dart_tool/package_config.json");

/** Compiles and executes complete generated builders against the workspace SDK. */
function runBuilder(node: InstructionNode, body: string) {
  const directory = mkdtempSync(join(tmpdir(), "renderer-signer-"));
  directories.push(directory);
  visit(rootNode(programNode({
    name: "signerFixture",
    publicKey: "11111111111111111111111111111111",
    instructions: [node],
  })), renderVisitor(directory));
  const source = readFileSync(join(directory, "instructions/action.dart"), "utf8");
  const file = join(directory, "proof.dart");
  writeFileSync(file, `
import 'package:solana_kit_addresses/solana_kit_addresses.dart';
import 'package:solana_kit_instructions/solana_kit_instructions.dart';
import 'instructions/action.dart';

void main() {
  const program = Address('11111111111111111111111111111111');
  const authority = Address('TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb');
  ${body}
}
`);
  const result = spawnSync("dart", [`--packages=${packageConfig}`, file], {
    encoding: "utf8",
    timeout: 30_000,
  });

  expect(result.error).toBeUndefined();
  expect(result.stderr).toBe("");
  expect(result.status).toBe(0);

  return { source, stdout: result.stdout.trim() };
}

afterEach(() => {
  for (const directory of directories.splice(0)) {
    rmSync(directory, { recursive: true, force: true });
  }
});

describe("generated either-signer account roles", () => {
  it.each([false, true])("supports a non-signing multisig authority (writable=%s)", (isWritable) => {
    const node = instructionNode({
      name: "action",
      accounts: [instructionAccountNode({ name: "authority", isSigner: "either", isWritable })],
      arguments: [],
    });
    const { source, stdout } = runBuilder(node, `
  final multisig = getActionInstruction(programAddress: program, authority: authority, authorityIsSigner: false);
  final signer = getActionInstruction(programAddress: program, authority: authority, authorityIsSigner: true);
  final legacy = getActionInstruction(programAddress: program, authority: authority);
  print([multisig, signer, legacy].map((instruction) => instruction.accounts!.single.role.value).join(','));
`);

    expect(source).toContain("bool authorityIsSigner = true,");
    expect(stdout).toBe(isWritable ? "1,3,3" : "0,2,2");
  });

  it.each([
    [false, "programId"],
    [true, "programId"],
    [false, "omitted"],
    [true, "omitted"],
  ] as const)("preserves optional account handling (writable=%s, strategy=%s)", (isWritable, optionalAccountStrategy) => {
    const node = instructionNode({
      name: "action",
      optionalAccountStrategy,
      accounts: [instructionAccountNode({
        name: "authority",
        isSigner: "either",
        isWritable,
        isOptional: true,
      })],
      arguments: [],
    });
    const { stdout } = runBuilder(node, `
  final present = getActionInstruction(programAddress: program, authority: authority, authorityIsSigner: false);
  final absent = getActionInstruction(programAddress: program, authorityIsSigner: true);
  print(present.accounts!.single.role.value);
  print(absent.accounts!.map((account) => '\${account.address.value}:\${account.role.value}').join(','));
`);

    const expectedRole = isWritable ? "1" : "0";
    expect(stdout).toBe(optionalAccountStrategy === "omitted"
      ? expectedRole
      : `${expectedRole}\n11111111111111111111111111111111:0`);
  });

  it("keeps fixed signer permissions fixed", () => {
    const node = instructionNode({
      name: "action",
      accounts: [
        instructionAccountNode({ name: "requiredSigner", isSigner: true, isWritable: true }),
        instructionAccountNode({ name: "readonlySigner", isSigner: true, isWritable: false }),
        instructionAccountNode({ name: "writable", isSigner: false, isWritable: true }),
        instructionAccountNode({ name: "readonly", isSigner: false, isWritable: false }),
      ],
      arguments: [],
    });
    const { source, stdout } = runBuilder(node, `
  final instruction = getActionInstruction(programAddress: program,
    requiredSigner: authority, readonlySigner: authority, writable: authority, readonly: authority);
  print(instruction.accounts!.map((account) => account.role.value).join(','));
`);

    expect(source).not.toContain("IsSigner = true");
    expect(stdout).toBe("3,2,1,0");
  });

  it("avoids account and argument names when adding signer parameters", () => {
    const node = instructionNode({
      name: "action",
      accounts: [
        instructionAccountNode({ name: "authority", isSigner: "either", isWritable: false }),
        instructionAccountNode({ name: "authorityIsSigner", isSigner: "either", isWritable: true }),
      ],
      arguments: [instructionArgumentNode({ name: "authorityIsSignerIsSigner", type: booleanTypeNode() })],
    });
    const { source, stdout } = runBuilder(node, `
  final instruction = getActionInstruction(programAddress: program,
    authority: authority, authorityIsSigner: authority, authorityIsSignerIsSigner: false,
    authorityIsSigner_: false, authorityIsSignerIsSigner_: false);
  print(instruction.accounts!.map((account) => account.role.value).join(','));
`);

    expect(source).toContain("bool authorityIsSigner_ = true,");
    expect(source).toContain("bool authorityIsSignerIsSigner_ = true,");
    expect(stdout).toBe("0,1");
  });

  it("reserves generated program and data names alongside signer parameters", () => {
    const node = instructionNode({
      name: "action",
      accounts: [
        instructionAccountNode({ name: "programAddress", isSigner: "either", isWritable: false }),
        instructionAccountNode({ name: "instructionProgramAddress", isSigner: false, isWritable: false }),
        instructionAccountNode({ name: "instructionData", isSigner: false, isWritable: false }),
      ],
      arguments: [],
    });
    const { source, stdout } = runBuilder(node, `
  final instruction = getActionInstruction(instructionProgramAddress_: program,
    programAddress: authority, instructionProgramAddress: authority, instructionData: authority,
    programAddressIsSigner: false);
  print(instruction.programAddress.value);
  print(instruction.accounts!.map((account) => account.role.value).join(','));
`);

    expect(source).toContain("required Address instructionProgramAddress_,");
    expect(source).toContain("final instructionData_ = ActionInstructionData(");
    expect(stdout).toBe("11111111111111111111111111111111\n0,0,0");
  });
});
