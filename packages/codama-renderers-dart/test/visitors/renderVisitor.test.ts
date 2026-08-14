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
