import { errorNode, programNode } from "@codama/nodes";
import { LinkableDictionary, NodeStack } from "@codama/visitors-core";
import { describe, expect, it } from "vitest";

import { getErrorPageFragment } from "../../src/fragments/errorPage.js";
import { createDartNameApi } from "../../src/utils/nameTransformers.js";
import type { RenderScope } from "../../src/utils/options.js";
import { getTypeManifestVisitor } from "../../src/visitors/getTypeManifestVisitor.js";

function createScope(): RenderScope {
  const nameApi = createDartNameApi();
  const linkables = new LinkableDictionary();
  const stack = new NodeStack();
  return {
    nameApi,
    typeManifestVisitor: getTypeManifestVisitor({
      nameApi,
      linkables,
      stack,
    }),
    linkables,
    dependencyMap: {},
    internalImportMap: {},
  };
}

describe("getErrorPageFragment", () => {
  it("generates error code constants", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      errors: [
        errorNode({
          name: "invalidOwner",
          code: 0,
          message: "The owner is invalid",
        }),
        errorNode({
          name: "insufficientFunds",
          code: 1,
          message: "Insufficient funds",
        }),
      ],
    });
    const frag = getErrorPageFragment(node, createScope());

    expect(frag.content).toContain("const int myProgramErrorInvalidOwner = 0x0;");
    expect(frag.content).toContain("const int myProgramErrorInsufficientFunds = 0x1;");
  });

  it("includes error messages as comments", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      errors: [
        errorNode({
          name: "invalidOwner",
          code: 0,
          message: "The owner is invalid",
        }),
      ],
    });
    const frag = getErrorPageFragment(node, createScope());

    expect(frag.content).toContain('Message: "The owner is invalid"');
  });

  it("generates error message map", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      errors: [
        errorNode({
          name: "invalidOwner",
          code: 0,
          message: "The owner is invalid",
        }),
      ],
    });
    const frag = getErrorPageFragment(node, createScope());

    expect(frag.content).toContain("_myProgramErrorMessages");
    expect(frag.content).toContain("myProgramErrorInvalidOwner: 'The owner is invalid'");
  });

  it("generates error message getter function", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      errors: [
        errorNode({
          name: "fail",
          code: 42,
          message: "Something failed",
        }),
      ],
    });
    const frag = getErrorPageFragment(node, createScope());

    expect(frag.content).toContain(
      "String? getMyProgramErrorMessage(int code)",
    );
    expect(frag.content).toContain(
      "_myProgramErrorMessages[code]",
    );
  });

  it("generates isError function", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      errors: [
        errorNode({
          name: "fail",
          code: 0,
          message: "Failed",
        }),
      ],
    });
    const frag = getErrorPageFragment(node, createScope());

    expect(frag.content).toContain("bool isMyProgramError(int code)");
    expect(frag.content).toContain(
      "_myProgramErrorMessages.containsKey(code)",
    );
  });

  it("returns empty fragment when there are no errors", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      errors: [],
    });
    const frag = getErrorPageFragment(node, createScope());

    expect(frag.content).toBe("");
  });

  it("uses hex code format in constants", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      errors: [
        errorNode({
          name: "notFound",
          code: 255,
          message: "Not found",
        }),
      ],
    });
    const frag = getErrorPageFragment(node, createScope());

    expect(frag.content).toContain("= 0xff;");
    expect(frag.content).toContain("// 255");
  });

  it("includes auto-generated header", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      errors: [
        errorNode({
          name: "fail",
          code: 0,
          message: "Failed",
        }),
      ],
    });
    const frag = getErrorPageFragment(node, createScope());

    expect(frag.content).toContain("// Auto-generated. Do not edit.");
  });

  it("includes docs from error nodes", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      errors: [
        errorNode({
          name: "invalidOwner",
          code: 0,
          message: "Invalid owner",
          docs: ["This error occurs when the owner is not valid."],
        }),
      ],
    });
    const frag = getErrorPageFragment(node, createScope());

    expect(frag.content).toContain(
      "/// This error occurs when the owner is not valid.",
    );
  });

  it("escapes single quotes in error messages", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      errors: [
        errorNode({
          name: "fail",
          code: 0,
          message: "It's broken",
        }),
      ],
    });
    const frag = getErrorPageFragment(node, createScope());

    expect(frag.content).toContain("It\\'s broken");
  });

  it("handles multiple errors with sequential codes", () => {
    const node = programNode({
      name: "myProgram",
      publicKey: "MyProgram1111111111111111111111111111111111",
      errors: [
        errorNode({ name: "err0", code: 0, message: "Error 0" }),
        errorNode({ name: "err1", code: 1, message: "Error 1" }),
        errorNode({ name: "err2", code: 2, message: "Error 2" }),
      ],
    });
    const frag = getErrorPageFragment(node, createScope());

    expect(frag.content).toContain("myProgramErrorErr0");
    expect(frag.content).toContain("myProgramErrorErr1");
    expect(frag.content).toContain("myProgramErrorErr2");
  });
});
