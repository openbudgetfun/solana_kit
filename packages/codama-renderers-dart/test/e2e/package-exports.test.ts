import { execFileSync } from "node:child_process";
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterAll, beforeAll, describe, it } from "vitest";

const packageDirectory = join(import.meta.dirname, "../..");
let consumerDirectory = "";
let packDirectory = "";

describe("published package exports", () => {
  beforeAll(() => {
    packDirectory = mkdtempSync(join(tmpdir(), "codama-dart-pack-"));
    consumerDirectory = mkdtempSync(join(tmpdir(), "codama-dart-consumer-"));

    writeFileSync(
      join(consumerDirectory, "package.json"),
      JSON.stringify({ name: "codama-dart-consumer", private: true }),
    );

    execFileSync("pnpm", ["run", "build"], {
      cwd: packageDirectory,
      stdio: "pipe",
      timeout: 120_000,
    });

    execFileSync("pnpm", ["pack", "--pack-destination", packDirectory], {
      cwd: packageDirectory,
      stdio: "pipe",
      timeout: 120_000,
    });

    const packageManifest = JSON.parse(
      readFileSync(join(packageDirectory, "package.json"), "utf8"),
    ) as { name: string; version: string };
    const tarballName = `${packageManifest.name.replace("/", "-")}-${packageManifest.version}.tgz`;
    const tarball = join(packDirectory, tarballName);

    execFileSync("pnpm", ["add", "--ignore-scripts", tarball], {
      cwd: consumerDirectory,
      stdio: "pipe",
      timeout: 120_000,
    });
  }, 180_000);

  afterAll(() => {
    if (consumerDirectory) {
      rmSync(consumerDirectory, { recursive: true, force: true });
    }

    if (packDirectory) {
      rmSync(packDirectory, { recursive: true, force: true });
    }
  });

  it("loads the node ESM export", () => {
    assertRendererImport(["--input-type=module"]);
  });

  it("loads the node CommonJS export", () => {
    assertRendererImport(["--input-type=commonjs"]);
  });

  it("loads the browser ESM and CommonJS exports", () => {
    assertRendererImport(["--conditions=browser", "--input-type=module"]);
    assertRendererImport(["--conditions=browser", "--input-type=commonjs"]);
  });

  it("loads the React Native ESM export", () => {
    assertRendererImport(["--conditions=react-native", "--input-type=module"]);
  });
});

function assertRendererImport(nodeArguments: string[]): void {
  const moduleSource = nodeArguments.includes("--input-type=commonjs")
    ? "const { renderVisitor } = require('codama-renderers-dart');"
    : "import { renderVisitor } from 'codama-renderers-dart';";

  execFileSync(
    process.execPath,
    [...nodeArguments, "--eval", `${moduleSource}\nif (typeof renderVisitor !== 'function') process.exit(1);`],
    {
      cwd: consumerDirectory,
      stdio: "pipe",
      timeout: 30_000,
    },
  );
}
