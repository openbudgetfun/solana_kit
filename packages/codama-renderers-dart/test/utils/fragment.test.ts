import { describe, expect, it } from "vitest";

import {
  emptyFragment,
  fragment,
  fragmentFromString,
  mergeFragments,
  use,
} from "../../src/utils/fragment.js";
import { DartImportMap } from "../../src/utils/importMap.js";

describe("fragment", () => {
  it("creates a fragment from a plain template string", () => {
    const f = fragment`hello world`;
    expect(f.content).toBe("hello world");
    expect(f.imports.isEmpty).toBe(true);
  });

  it("interpolates string values", () => {
    const name = "Foo";
    const f = fragment`class ${name} {}`;
    expect(f.content).toBe("class Foo {}");
    expect(f.imports.isEmpty).toBe(true);
  });

  it("interpolates number values", () => {
    const count = 42;
    const f = fragment`count: ${count}`;
    expect(f.content).toBe("count: 42");
  });

  it("interpolates boolean values", () => {
    const f = fragment`flag: ${true}`;
    expect(f.content).toBe("flag: true");
  });

  it("interpolates null as empty string", () => {
    const f = fragment`value: ${null}`;
    expect(f.content).toBe("value: ");
  });

  it("interpolates undefined as empty string", () => {
    const f = fragment`value: ${undefined}`;
    expect(f.content).toBe("value: ");
  });

  it("interpolates another Fragment and merges its imports", () => {
    const inner = use("Uint8List", "dartTypedData");
    const outer = fragment`final x = ${inner};`;
    expect(outer.content).toBe("final x = Uint8List;");
    expect(outer.imports.modules.has("dartTypedData")).toBe(true);
  });

  it("merges imports from multiple embedded fragments", () => {
    const a = use("Address", "solanaAddresses");
    const b = use("Uint8List", "dartTypedData");
    const f = fragment`${a} and ${b}`;
    expect(f.content).toBe("Address and Uint8List");
    expect(f.imports.modules.has("solanaAddresses")).toBe(true);
    expect(f.imports.modules.has("dartTypedData")).toBe(true);
  });

  it("handles mixed string and fragment interpolation", () => {
    const inner = use("Encoder", "solanaCodecsCore");
    const f = fragment`class ${"Foo"} extends ${inner} { ${42} }`;
    expect(f.content).toBe("class Foo extends Encoder { 42 }");
    expect(f.imports.modules.has("solanaCodecsCore")).toBe(true);
  });
});

describe("emptyFragment", () => {
  it("creates a fragment with empty content", () => {
    const f = emptyFragment();
    expect(f.content).toBe("");
    expect(f.imports.isEmpty).toBe(true);
  });
});

describe("fragmentFromString", () => {
  it("creates a fragment from a raw string", () => {
    const f = fragmentFromString("int x = 0;");
    expect(f.content).toBe("int x = 0;");
    expect(f.imports.isEmpty).toBe(true);
  });

  it("does not parse any template syntax in the string", () => {
    const f = fragmentFromString("${notInterpolated}");
    expect(f.content).toBe("${notInterpolated}");
  });
});

describe("mergeFragments", () => {
  it("merges content using a joiner function", () => {
    const a = fragmentFromString("line1");
    const b = fragmentFromString("line2");
    const merged = mergeFragments([a, b], (cs) => cs.join("\n"));
    expect(merged.content).toBe("line1\nline2");
  });

  it("merges imports from all fragments", () => {
    const a = use("Encoder", "solanaCodecsCore");
    const b = use("Address", "solanaAddresses");
    const merged = mergeFragments([a, b], (cs) => cs.join(", "));
    expect(merged.content).toBe("Encoder, Address");
    expect(merged.imports.modules.has("solanaCodecsCore")).toBe(true);
    expect(merged.imports.modules.has("solanaAddresses")).toBe(true);
  });

  it("handles an empty array of fragments", () => {
    const merged = mergeFragments([], (cs) => cs.join(", "));
    expect(merged.content).toBe("");
    expect(merged.imports.isEmpty).toBe(true);
  });

  it("allows custom joiner such as comma-separated", () => {
    const frags = [
      fragmentFromString("a"),
      fragmentFromString("b"),
      fragmentFromString("c"),
    ];
    const merged = mergeFragments(frags, (cs) => cs.join(", "));
    expect(merged.content).toBe("a, b, c");
  });
});

describe("use", () => {
  it("creates a fragment with the type name as content", () => {
    const f = use("Uint8List", "dartTypedData");
    expect(f.content).toBe("Uint8List");
  });

  it("adds the module to imports", () => {
    const f = use("Uint8List", "dartTypedData");
    expect(f.imports.modules.has("dartTypedData")).toBe(true);
    expect(f.imports.modules.size).toBe(1);
  });

  it("can be used with any module name", () => {
    const f = use("Address", "solanaAddresses");
    expect(f.content).toBe("Address");
    expect(f.imports.modules.has("solanaAddresses")).toBe(true);
  });

  it("can be used with raw URI strings", () => {
    const f = use("SomeType", "package:my_package/my_package.dart");
    expect(f.content).toBe("SomeType");
    expect(f.imports.modules.has("package:my_package/my_package.dart")).toBe(
      true,
    );
  });
});
