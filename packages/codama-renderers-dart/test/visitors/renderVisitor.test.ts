import { readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

import {
  definedTypeLinkNode,
  definedTypeNode,
  numberTypeNode,
  programNode,
  rootNode,
  structFieldTypeNode,
  structTypeNode,
} from "@codama/nodes";
import { visit } from "@codama/visitors-core";
import { afterEach, describe, expect, it } from "vitest";

import { renderVisitor } from "../../src/visitors/renderVisitor.js";

describe("renderVisitor defined type imports", () => {
  const outputDirectories: string[] = [];

  afterEach(() => {
    for (const outputDir of outputDirectories) {
      rmSync(outputDir, { recursive: true, force: true });
    }

    outputDirectories.length = 0;
  });

  it("resolves defined types whose names contain digits", () => {
    const outputDir = createOutputDirectory();
    const root = rootNode(
      programNode({
        name: "definedTypeImports",
        publicKey: "11111111111111111111111111111111",
        definedTypes: [
          definedTypeNode({ name: "type2", type: numberTypeNode("u64") }),
          definedTypeNode({
            name: "container",
            type: structTypeNode([
              structFieldTypeNode({
                name: "value",
                type: definedTypeLinkNode("type2"),
              }),
            ]),
          }),
        ],
      }),
    );

    visit(root, renderVisitor(outputDir));

    const content = readFileSync(join(outputDir, "types/container.dart"), "utf8");
    expect(content).toContain("import './type2.dart';");
    expect(content).not.toContain("definedType:");
  });

  it("rejects links to missing defined types", () => {
    const outputDir = createOutputDirectory();
    const root = rootNode(
      programNode({
        name: "missingDefinedType",
        publicKey: "11111111111111111111111111111111",
        definedTypes: [
          definedTypeNode({
            name: "container",
            type: structTypeNode([
              structFieldTypeNode({
                name: "value",
                type: definedTypeLinkNode("missingType"),
              }),
            ]),
          }),
        ],
      }),
    );

    expect(() => visit(root, renderVisitor(outputDir))).toThrowError(
      'Unresolved Dart import module "definedType:missing_type"',
    );
  });

  function createOutputDirectory(): string {
    const outputDir = join(
      tmpdir(),
      `codama-dart-render-${Date.now()}-${Math.random().toString(36).slice(2)}`,
    );
    outputDirectories.push(outputDir);

    return outputDir;
  }
});

describe("renderVisitor link overrides", () => {
  const outputDirectories: string[] = [];

  afterEach(() => {
    for (const outputDir of outputDirectories) {
      rmSync(outputDir, { recursive: true, force: true });
    }

    outputDirectories.length = 0;
  });

  function createOutputDirectory(...segments: string[]): string {
    const outputDir = join(
      tmpdir(),
      `codama-dart-link-override-${Date.now()}-${Math.random().toString(36).slice(2)}`,
      ...segments,
    );
    outputDirectories.push(join(outputDir, ".."));

    return outputDir;
  }

  function rootWithLink() {
    return rootNode(
      programNode({
        name: "withLink",
        publicKey: "11111111111111111111111111111111",
        definedTypes: [
          definedTypeNode({
            name: "container",
            type: structTypeNode([
              structFieldTypeNode({
                name: "items",
                type: definedTypeLinkNode("extensions"),
              }),
            ]),
          }),
        ],
      }),
    );
  }

  it("imports the override file relative to the generated file", () => {
    // Output inside `lib/src/generated`; the override lives at `lib/src/...`.
    const outputDir = createOutputDirectory("lib", "src", "generated");
    visit(
      rootWithLink(),
      renderVisitor(outputDir, {
        linkOverrides: {
          extensions: {
            path: "src/extensions.dart",
            type: "List<Extension>",
            encoder: "getExtensionsEncoder()",
            decoder: "getExtensionsDecoder()",
          },
        },
      }),
    );

    const content = readFileSync(
      join(outputDir, "types/container.dart"),
      "utf8",
    );
    expect(content).toContain("import '../../extensions.dart';");
    expect(content).toContain("List<Extension>");
    expect(content).toContain("getExtensionsEncoder()");
    expect(content).toContain("getExtensionsDecoder()");
  });

  it("prefixes a relative import that would start at the current directory", () => {
    // The override sits in the same directory as the generated file, so the
    // relative path has no leading dot and must gain one to stay a relative
    // import.
    const outputDir = createOutputDirectory("lib", "generated");
    visit(
      rootWithLink(),
      renderVisitor(outputDir, {
        linkOverrides: {
          extensions: {
            path: "generated/types/extensions.dart",
            type: "List<Extension>",
            encoder: "getExtensionsEncoder()",
            decoder: "getExtensionsDecoder()",
          },
        },
      }),
    );

    const content = readFileSync(
      join(outputDir, "types/container.dart"),
      "utf8",
    );
    expect(content).toContain("import './extensions.dart';");
  });

  it("rejects overrides when the output has no lib ancestor", () => {
    // Override paths are anchored to `lib/`, so an output tree without one
    // cannot resolve them and must fail rather than emit a broken import.
    const outputDir = createOutputDirectory("out");
    expect(() =>
      visit(
        rootWithLink(),
        renderVisitor(outputDir, {
          linkOverrides: {
            extensions: {
              path: "src/extensions.dart",
              type: "List<Extension>",
              encoder: "getExtensionsEncoder()",
              decoder: "getExtensionsDecoder()",
            },
          },
        }),
      ),
    ).toThrowError(/has no "lib" ancestor/);
  });

  it("ignores an empty override map", () => {
    // No overrides means no `linkOverride:` imports to resolve, so a normal
    // defined type still renders unchanged.
    const outputDir = createOutputDirectory("lib", "src", "generated");
    const root = rootNode(
      programNode({
        name: "noOverrides",
        publicKey: "11111111111111111111111111111111",
        definedTypes: [
          definedTypeNode({ name: "inner", type: numberTypeNode("u64") }),
          definedTypeNode({
            name: "container",
            type: structTypeNode([
              structFieldTypeNode({
                name: "value",
                type: definedTypeLinkNode("inner"),
              }),
            ]),
          }),
        ],
      }),
    );

    visit(root, renderVisitor(outputDir, { linkOverrides: {} }));

    const content = readFileSync(
      join(outputDir, "types/container.dart"),
      "utf8",
    );
    expect(content).toContain("import './inner.dart';");
  });
});
