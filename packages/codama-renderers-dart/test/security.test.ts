import { spawnSync } from "node:child_process";
import { existsSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
  accountNode,
  constantPdaSeedNodeFromString,
  errorNode,
  pdaNode,
  programNode,
  rootNode,
  structTypeNode,
  type ProgramNode,
} from "@codama/nodes";
import { visit } from "@codama/visitors-core";
import { afterEach, describe, expect, it } from "vitest";
import { formatDartDirectory } from "../src/utils/formatCode.js";
import { getRenderMapVisitor } from "../src/visitors/getRenderMapVisitor.js";
import { renderVisitor } from "../src/visitors/renderVisitor.js";

const directories: string[] = [];

function temporaryDirectory(): string {
  const directory = mkdtempSync(join(tmpdir(), "renderer-security-"));
  directories.push(directory);
  return directory;
}

function runDart(source: string) {
  const file = join(temporaryDirectory(), "proof.dart");
  writeFileSync(file, source);
  return spawnSync("dart", [file], { encoding: "utf8", timeout: 30_000 });
}

afterEach(() => {
  for (const directory of directories.splice(0)) {
    rmSync(directory, { recursive: true, force: true });
  }
});

describe("renderer security boundaries", () => {
  it("replaces previous output only after a valid client has been rendered", () => {
    const output = temporaryDirectory();
    const staleFile = join(output, "stale.dart");
    writeFileSync(staleFile, "old generated source");
    const root = rootNode(programNode({ name: "safe", publicKey: "11111111111111111111111111111111" }));

    visit(root, renderVisitor(output));

    expect(existsSync(staleFile)).toBe(false);
    expect(readFileSync(join(output, "programs/safe.dart"), "utf8")).toContain("safeProgramAddress");
  });

  it.each(["0; void injected() {} //", -1, 1.5, Number.MAX_SAFE_INTEGER + 1])(
    "rejects invalid account byte size %j",
    (size) => {
      const account = { ...accountNode({ name: "safe", data: structTypeNode([]) }), size: size as number };
      const program = programNode({ name: "safe", publicKey: "11111111111111111111111111111111", accounts: [account] });
      expect(() => visit(rootNode(program), getRenderMapVisitor())).toThrow(/non-negative safe integer/);
    },
  );

  it.each(["0; void injected() {} //", -1, 1.5, Number.MAX_SAFE_INTEGER + 1])(
    "rejects invalid error code %j",
    (code) => {
      const error = { ...errorNode({ name: "failure", code: 1 }), code: code as number };
      const program = programNode({ name: "safe", publicKey: "11111111111111111111111111111111", errors: [error] });
      expect(() => visit(rootNode(program), getRenderMapVisitor())).toThrow(/non-negative safe integer/);
    },
  );

  it("passes formatter paths literally without executing shell substitutions", () => {
    const directory = temporaryDirectory();
    const marker = join(directory, "executed");
    const target = join(directory, `$(touch '${marker}')`);
    mkdirSync(target, { recursive: true });
    writeFileSync(join(target, "safe.dart"), "void main(){}");

    formatDartDirectory(target);

    expect(existsSync(marker), "formatter executed an injected shell command").toBe(false);
    expect(readFileSync(join(target, "safe.dart"), "utf8")).toBe("void main() {}\n");
  });

  it("rejects traversal names before deleting existing generated output", () => {
    const directory = temporaryDirectory();
    const output = join(directory, "output");
    mkdirSync(output);
    writeFileSync(join(output, "keep.txt"), "existing generated content");
    const program: ProgramNode = {
      ...programNode({ name: "safe", publicKey: "11111111111111111111111111111111" }),
      name: "../escaped" as ProgramNode["name"],
    };
    let failure: unknown;
    try {
      visit(rootNode(program), renderVisitor(output));
    } catch (error) {
      failure = error;
    }

    expect(existsSync(join(directory, "escaped.dart")), "IDL wrote outside output directory").toBe(false);
    expect(failure).toBeInstanceOf(Error);
    expect(readFileSync(join(output, "keep.txt"), "utf8")).toBe("existing generated content");
  });

  it.each(["\n", "\r", "\r\n"])("keeps embedded %j line endings inside error documentation", (newline) => {
    const maliciousDocs = `Error docs${newline}void main() { print('IDL_CODE_EXECUTED'); }${newline}///`;
    const program = programNode({
      name: "safe",
      publicKey: "11111111111111111111111111111111",
      errors: [errorNode({ name: "failure", code: 1, docs: [maliciousDocs] })],
    });
    const content = visit(rootNode(program), getRenderMapVisitor()).get("errors/safe.dart")!.content;
    const result = runDart(content);

    expect(result.stdout, "IDL documentation injected an executable Dart main").not.toContain("IDL_CODE_EXECUTED");
    expect(content).toContain("/// void main() { print('IDL_CODE_EXECUTED'); }");
  });

  it("keeps multiline error messages inside comments and preserves string contents", () => {
    const message = "Failure\nvoid main() { print('IDL_CODE_EXECUTED'); }\n/// $value \\ ' \r\t";
    const program = programNode({
      name: "safe",
      publicKey: "11111111111111111111111111111111",
      errors: [errorNode({ name: "failure", code: 1, message })],
    });
    const content = visit(rootNode(program), getRenderMapVisitor()).get("errors/safe.dart")!.content;
    const result = runDart(`${content}\nvoid main() {\n  if (getSafeErrorMessage(1) != String.fromCharCodes(${JSON.stringify([...message].map((char) => char.charCodeAt(0)))})) {\n    throw StateError('Error message changed');\n  }\n}`);

    expect(result.stderr).toBe("");
    expect(result.status).toBe(0);
  });

  it.each([
    "${(() { throw StateError('IDL_CODE_EXECUTED'); })()}",
    "literal \\ \n \r \t ' $seed",
  ])("preserves constant PDA string seed %j without evaluating it", (payload) => {
    const program = programNode({
      name: "safe",
      publicKey: "11111111111111111111111111111111",
      pdas: [pdaNode({ name: "unsafe", seeds: [constantPdaSeedNodeFromString("utf8", payload)] })],
    });
    const content = visit(rootNode(program), getRenderMapVisitor()).get("pdas/unsafe.dart")!.content;
    const seedList = content.match(/final seedValues = <Object>\[[\s\S]*?\];/)![0];
    const result = runDart(`void main() {\n${seedList}\n  if (seedValues.single != String.fromCharCodes(${JSON.stringify([...payload].map((char) => char.charCodeAt(0)))})) {\n    throw StateError('Seed changed');\n  }\n}`);

    expect(result.stderr).toBe("");
    expect(result.status).toBe(0);
  });
});
