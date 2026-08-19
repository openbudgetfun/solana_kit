import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach, describe, expect, it } from "vitest";

import { formatDartCode, formatDartDirectory } from "../../src/utils/formatCode.js";

describe("Dart formatting", () => {
  const temporaryDirectories: string[] = [];

  afterEach(() => {
    for (const directory of temporaryDirectories) {
      rmSync(directory, { recursive: true, force: true });
    }
  });

  it("formats a Dart source string", () => {
    expect(formatDartCode("void main(){print('hello');}")).toBe(
      "void main() {\n  print('hello');\n}\n",
    );
  });

  it("leaves source unchanged when Dart cannot format it", () => {
    const invalidDart = "void main( {";

    expect(formatDartCode(invalidDart)).toBe(invalidDart);
  });

  it("formats every Dart file in a directory", () => {
    const directory = mkdtempSync(join(tmpdir(), "codama-dart-format-"));
    const sourceFile = join(directory, "example.dart");
    temporaryDirectories.push(directory);
    writeFileSync(sourceFile, "void main(){print('hello');}");

    formatDartDirectory(directory);

    expect(readFileSync(sourceFile, "utf8")).toBe(
      "void main() {\n  print('hello');\n}\n",
    );
  });
});
