import assert from "node:assert/strict";
import * as fs from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { mock, test } from "node:test";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const rendererDir = join(root, "packages/codama-renderers-dart");
let importId = 0;

async function runGenerator(t, { check = true, generated = "fresh", existing = "stale", fail = false } = {}) {
  const fixture = fs.mkdtempSync(join(tmpdir(), "program-generator-test-"));
  const fixtureRoot = join(fixture, "repo");
  const privateTmp = join(fixture, "tmp");
  const generatedDir = join(fixtureRoot, "packages/solana_kit_system/lib/src/generated");
  const previousArgv = process.argv;
  const previousExitCode = process.exitCode;

  t.after(() => fs.rmSync(fixture, { recursive: true, force: true }));
  fs.mkdirSync(join(fixtureRoot, ".repos/solana-program/system"), { recursive: true });
  fs.mkdirSync(join(generatedDir, "nested"), { recursive: true });
  fs.mkdirSync(privateTmp);
  fs.writeFileSync(join(fixtureRoot, ".repos/solana-program/system/idl.json"), JSON.stringify({ kind: "rootNode", program: {} }));
  fs.writeFileSync(join(generatedDir, "output.dart"), existing);
  fs.writeFileSync(join(generatedDir, "nested/output.dart"), existing);

  function mapPath(file) {
    if (file === root || file.startsWith(`${root}/`)) return join(fixtureRoot, file.slice(root.length));
    return file;
  }

  const fsMock = mock.module("fs", {
    namedExports: {
      existsSync: file => fs.existsSync(mapPath(file)),
      mkdtempSync: (prefix, ...args) => fs.mkdtempSync(prefix, ...args),
      readFileSync: (file, ...args) => fs.readFileSync(mapPath(file), ...args),
      readdirSync: (file, ...args) => fs.readdirSync(mapPath(file), ...args),
      rmSync: (file, ...args) => fs.rmSync(mapPath(file), ...args),
      statSync: (file, ...args) => fs.statSync(mapPath(file), ...args),
    },
  });
  const osMock = mock.module("os", { namedExports: { tmpdir: () => privateTmp } });
  const rendererMock = mock.module(join(rendererDir, "dist/index.node.js"), {
    namedExports: {
      renderVisitor(output) {
        return () => {
          if (fail) throw new Error("renderer rejected IDL");
          const target = mapPath(output);
          fs.rmSync(target, { recursive: true, force: true });
          fs.mkdirSync(join(target, "nested"), { recursive: true });
          fs.writeFileSync(join(target, "output.dart"), generated);
          fs.writeFileSync(join(target, "nested/output.dart"), generated);
        };
      },
    },
  });
  const visitorsMock = mock.module(join(rendererDir, "node_modules/@codama/visitors-core/dist/index.node.mjs"), {
    namedExports: { visit: (rootNode, visitor) => visitor(rootNode) },
  });
  const nodesMock = mock.module(join(rendererDir, "node_modules/@codama/nodes/dist/index.node.mjs"), {
    namedExports: Object.fromEntries([
      "accountNode", "definedTypeLinkNode", "definedTypeNode", "instructionArgumentNode",
      "numberTypeNode", "structFieldTypeNode", "structTypeNode",
    ].map(name => [name, (...args) => ({ kind: name, args })])),
  });
  t.after(() => {
    nodesMock.restore();
    visitorsMock.restore();
    rendererMock.restore();
    osMock.restore();
    fsMock.restore();
    process.argv = previousArgv;
    process.exitCode = previousExitCode;
  });

  process.argv = [process.execPath, "generate_program_packages.mjs", "--program=system", ...(check ? ["--check"] : [])];
  process.exitCode = undefined;
  await import(`./generate_program_packages.mjs?case=${++importId}`);

  return {
    exitCode: process.exitCode ?? 0,
    output: fs.readFileSync(join(generatedDir, "output.dart"), "utf8"),
    temporaryEntries: fs.readdirSync(privateTmp),
  };
}

test("check mode reports generated output drift without changing the workspace", async (t) => {
  const result = await runGenerator(t);

  assert.equal(result.exitCode, 1);
  assert.equal(result.output, "stale");
  assert.deepEqual(result.temporaryEntries, []);
});

test("check mode succeeds when generated output is current", async (t) => {
  const result = await runGenerator(t, { existing: "fresh" });

  assert.equal(result.exitCode, 0);
  assert.equal(result.output, "fresh");
  assert.deepEqual(result.temporaryEntries, []);
});

test("render failures make generation fail and clean temporary output", async (t) => {
  const result = await runGenerator(t, { fail: true });

  assert.equal(result.exitCode, 1);
  assert.equal(result.output, "stale");
  assert.deepEqual(result.temporaryEntries, []);
});

test("write mode updates generated output", async (t) => {
  const result = await runGenerator(t, { check: false });

  assert.equal(result.exitCode, 0);
  assert.equal(result.output, "fresh");
  assert.deepEqual(result.temporaryEntries, []);
});
