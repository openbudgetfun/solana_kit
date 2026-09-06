import { spawnSync } from "node:child_process";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import {
  arrayTypeNode,
  booleanTypeNode,
  booleanValueNode,
  bytesTypeNode,
  constantValueNode,
  fixedCountNode,
  fixedSizeTypeNode,
  hiddenPrefixTypeNode,
  mapTypeNode,
  numberTypeNode,
  numberValueNode,
  optionTypeNode,
  postOffsetTypeNode,
  preOffsetTypeNode,
  prefixedCountNode,
  setTypeNode,
  sizePrefixTypeNode,
  structFieldTypeNode,
  structTypeNode,
  type TypeNode,
} from "@codama/nodes";
import { LinkableDictionary, NodeStack, visit } from "@codama/visitors-core";
import { describe, expect, it } from "vitest";

import { createDartNameApi } from "../src/utils/nameTransformers.js";
import { getDartValueFragment } from "../src/utils/valueNodes.js";
import { getTypeManifestVisitor } from "../src/visitors/getTypeManifestVisitor.js";

function manifest(node: TypeNode) {
  return visit(node, getTypeManifestVisitor({
    nameApi: createDartNameApi(),
    linkables: new LinkableDictionary(),
    stack: new NodeStack(),
  }));
}

function compactCountPrefix(offset: number) {
  return postOffsetTypeNode(
    preOffsetTypeNode(numberTypeNode("u16", "be"), offset, "absolute"),
    0,
    "preOffset",
  );
}

// JSON IDLs are runtime data: TypeScript types cannot constrain these values.
const attack = "(() { throw StateError('injected'); })()";

describe("serialized IDL numeric code injection", () => {
  it.each([attack, null, true, {}, Number.NaN, Number.POSITIVE_INFINITY])(
    "rejects invalid standalone numeric value %j", (number) => {
      expect(() => getDartValueFragment({ kind: "numberValueNode", number } as never))
        .toThrow(/Invalid Dart number/);
    },
  );

  it.each([attack, 1, null])("rejects invalid boolean value %j", (boolean) => {
    expect(() => getDartValueFragment({ kind: "booleanValueNode", boolean } as never))
      .toThrow(/Invalid Dart boolean/);
  });

  it("keeps valid finite numbers and boolean values", () => {
    expect(getDartValueFragment(numberValueNode(1.5)).content).toBe("1.5");
    expect(getDartValueFragment(numberValueNode(-42), "BigInt").content).toBe("BigInt.from(-42)");
    expect(getDartValueFragment(booleanValueNode(false)).content).toBe("false");
  });

  it.each([1.5, Number.MAX_SAFE_INTEGER + 1])("rejects lossy BigInt literal %j", (value) => {
    expect(() => getDartValueFragment(numberValueNode(value), "BigInt"))
      .toThrow(/safe integer/);
  });

  it.each([attack, -1, 1.5, Number.MAX_SAFE_INTEGER + 1])(
    "rejects invalid fixed size %j", (size) => {
      expect(() => manifest({ kind: "fixedSizeTypeNode", type: bytesTypeNode(), size } as never))
        .toThrow(/non-negative safe integer/);
    },
  );

  it.each(["array", "map", "set"])("rejects executable %s count", (kind) => {
    const count = { kind: "fixedCountNode", value: attack } as never;
    const node = kind === "array" ? arrayTypeNode(numberTypeNode("u8"), count)
      : kind === "map" ? mapTypeNode(numberTypeNode("u8"), numberTypeNode("u8"), count)
      : setTypeNode(numberTypeNode("u8"), count);
    expect(() => manifest(node)).toThrow(/non-negative safe integer/);
  });

  it("retains zero and positive fixed sizes and collection counts", () => {
    expect(manifest(fixedSizeTypeNode(bytesTypeNode(), 0)).encoder.content).toContain(", 0, allowTruncation: false)");
    expect(manifest(arrayTypeNode(numberTypeNode("u8"), fixedCountNode(2))).encoder.content).toContain("FixedArraySize(2)");
    expect(manifest(mapTypeNode(numberTypeNode("u8"), numberTypeNode("u8"), fixedCountNode(0))).decoder.content).toContain("FixedArraySize(0)");
    expect(manifest(setTypeNode(numberTypeNode("u8"), fixedCountNode(1))).decoder.content).toContain("FixedArraySize(1)");
  });

  it("rejects executable hidden constant padding", () => {
    const node = hiddenPrefixTypeNode(numberTypeNode("u8"), [constantValueNode(
      { kind: "preOffsetTypeNode", type: numberTypeNode("u8"), offset: attack, strategy: "padded" } as never,
      numberValueNode(1),
    )]);
    expect(() => manifest(node)).toThrow(/safe integer/);
  });

  it("rejects executable hidden numeric constants", () => {
    const node = hiddenPrefixTypeNode(numberTypeNode("u8"), [constantValueNode(
      numberTypeNode("u8"), { kind: "numberValueNode", number: attack } as never,
    )]);
    expect(() => manifest(node)).toThrow(/Invalid Dart number/);
  });

  it("escapes raw inline struct field names", () => {
    const node = structTypeNode([{ kind: "structFieldTypeNode", name: "${throwInjected()}'", type: numberTypeNode("u8") } as never]);
    const rendered = manifest(node);
    expect(rendered.encoder.content).toContain("('\\${throwInjected()}\\'",);
    expect(rendered.decoder.content).toContain("('\\${throwInjected()}\\'",);
  });
});

describe("prefix byte order fidelity", () => {
  it.each(["array", "map", "set", "option", "size"])("retains big-endian %s prefixes", (kind) => {
    const number = numberTypeNode("u16", "be");
    const item = numberTypeNode("u8");
    const node = kind === "array" ? arrayTypeNode(item, prefixedCountNode(number))
      : kind === "map" ? mapTypeNode(item, item, prefixedCountNode(number))
      : kind === "set" ? setTypeNode(item, prefixedCountNode(number))
      : kind === "option" ? optionTypeNode(item, { prefix: number })
      : sizePrefixTypeNode(item, number);
    const rendered = manifest(node);
    expect(rendered.encoder.content).toContain("getU16Encoder(NumberCodecConfig(endian: Endian.big))");
    expect(rendered.decoder.content).toContain("getU16Decoder(NumberCodecConfig(endian: Endian.big))");
  });

  it("retains big-endian BigInt size prefixes", () => {
    const rendered = manifest(sizePrefixTypeNode(bytesTypeNode(), numberTypeNode("u64", "be")));
    expect(rendered.encoder.content).toContain("getU64Encoder(NumberCodecConfig(endian: Endian.big))");
    expect(rendered.decoder.content).toContain("getU64Decoder(NumberCodecConfig(endian: Endian.big))");
  });
});

describe("offset wire layout fidelity", () => {
  it.each([
    ["preOffsetTypeNode", "padded", 2, "padLeft"],
    ["postOffsetTypeNode", "padded", 2, "padRight"],
    ["preOffsetTypeNode", "relative", 2, "scope.preOffset + 2"],
    ["postOffsetTypeNode", "relative", -1, "scope.postOffset + -1"],
    ["postOffsetTypeNode", "preOffset", 1, "scope.preOffset + 1"],
    ["preOffsetTypeNode", "absolute", 0, "=> 0"],
    ["postOffsetTypeNode", "absolute", -1, "scope.wrapBytes(-1)"],
  ] as const)("preserves %s %s at %i", (kind, strategy, offset, expected) => {
    const rendered = manifest({ kind, strategy, offset, type: numberTypeNode("u8") } as TypeNode);
    expect(rendered.encoder.content).toContain(expected);
    expect(rendered.decoder.content).toContain(expected);
  });

  it.each(["preOffsetTypeNode", "postOffsetTypeNode"] as const)("rejects executable %s offsets", (kind) => {
    expect(() => manifest({ kind, type: numberTypeNode("u8"), strategy: "relative", offset: attack } as never))
      .toThrow(/safe integer/);
  });

  it("rejects unsupported offset strategy", () => {
    expect(() => manifest({ kind: "preOffsetTypeNode", type: numberTypeNode("u8"), strategy: "invalid", offset: 1 } as never))
      .toThrow(/Unsupported offset strategy/);
  });

  it("encodes padded wide hidden constants with the correct type and byte order", () => {
    const rendered = manifest(hiddenPrefixTypeNode(numberTypeNode("u8"), [constantValueNode(
      { kind: "preOffsetTypeNode", type: numberTypeNode("u64", "be"), offset: 2, strategy: "padded" },
      numberValueNode(9),
    )]));
    expect(rendered.encoder.content).toContain("padLeftEncoder(getU64Encoder(NumberCodecConfig(endian: Endian.big)), 2).encode(BigInt.from(9))");
    expect(rendered.decoder.content).toContain(".encode(BigInt.from(9))");
  });

  it.each(["array", "map", "set"])(
    "preserves nested offset codecs for %s length prefixes",
    (kind) => {
      const prefix = prefixedCountNode(compactCountPrefix(4));
      const item = numberTypeNode("u8");
      const node = kind === "array" ? arrayTypeNode(item, prefix)
        : kind === "map" ? mapTypeNode(item, item, prefix)
        : setTypeNode(item, prefix);
      const rendered = manifest(node);

      expect(rendered.encoder.content).toContain(
        "PrefixedArraySize(offsetEncoder(offsetEncoder(getU16Encoder(NumberCodecConfig(endian: Endian.big)), OffsetConfig(preOffset: (scope) => 4)), OffsetConfig(postOffset: (scope) => scope.preOffset + 0)))",
      );
      expect(rendered.decoder.content).toContain(
        "PrefixedArraySize(offsetDecoder(offsetDecoder(getU16Decoder(NumberCodecConfig(endian: Endian.big)), OffsetConfig(preOffset: (scope) => 4)), OffsetConfig(postOffset: (scope) => scope.preOffset + 0)))",
      );
    },
  );
});

describe("hidden affix constant validation", () => {
  it("rejects unsupported constant value types", () => {
    expect(() => manifest(hiddenPrefixTypeNode(numberTypeNode("u8"), [constantValueNode(
      numberTypeNode("u8"), booleanValueNode(true),
    )]))).toThrow(/Unsupported hidden affix constant value kind/);
  });

  it("rejects a numeric value paired with a nonnumeric codec", () => {
    expect(() => manifest(hiddenPrefixTypeNode(numberTypeNode("u8"), [constantValueNode(
      bytesTypeNode(), numberValueNode(1),
    )]))).toThrow(/Unsupported hidden affix constant type kind/);
  });
});


describe("generated prefix codecs compile and preserve wire bytes", () => {
  const prefix = numberTypeNode("u16", "be");
  const bool = booleanTypeNode();
  const compactTails = structTypeNode([
    structFieldTypeNode({
      name: "flags",
      type: preOffsetTypeNode(
        arrayTypeNode(bool, prefixedCountNode(compactCountPrefix(0))),
        4,
        "relative",
      ),
    }),
    structFieldTypeNode({
      name: "values",
      type: arrayTypeNode(
        numberTypeNode("u8"),
        prefixedCountNode(compactCountPrefix(2)),
      ),
    }),
  ]);
  const cases = [
    { node: prefix, value: "258", bytes: [1, 2] },
    { node: arrayTypeNode(bool, prefixedCountNode(prefix)), value: "[true]", bytes: [0, 1, 1] },
    { node: mapTypeNode(bool, bool, prefixedCountNode(prefix)), value: "{true: false}", bytes: [0, 1, 1, 0] },
    { node: setTypeNode(bool, prefixedCountNode(prefix)), value: "{true}", bytes: [0, 1, 1] },
    { node: optionTypeNode(bool, { prefix }), value: "true", bytes: [0, 1, 1] },
    { node: sizePrefixTypeNode(bool, prefix), value: "true", bytes: [0, 1, 1] },
    { node: sizePrefixTypeNode(bool, numberTypeNode("u64", "be")), value: "true", bytes: [0, 0, 0, 0, 0, 0, 0, 1, 1] },
    {
      node: compactTails,
      value: "{'flags': [true, false], 'values': [7, 8, 9]}",
      bytes: [0, 2, 0, 3, 1, 0, 7, 8, 9],
    },
  ];

  it.each(cases)("tracks imports for $node.kind", ({ node }) => {
    const rendered = manifest(node);

    for (const codec of [rendered.encoder, rendered.decoder]) {
      expect(codec.imports.modules.has("solanaCodecsNumbers")).toBe(true);
      expect(codec.imports.modules.has("dartTypedData")).toBe(true);
    }
  });

  it("compiles and executes generated encoders and decoders using tracked imports", () => {
    const directory = mkdtempSync(join(tmpdir(), "renderer-manifest-"));
    const imports = new Set<string>();
    const checks = cases.map(({ node, value, bytes }, index) => {
      const rendered = manifest(node);
      for (const codec of [rendered.encoder, rendered.decoder]) {
        for (const uri of codec.imports.resolve()) imports.add(uri);
      }
      return `
  final encoded${index} = ${rendered.encoder.content}.encode(${value});
  if (encoded${index}.toString() != ${JSON.stringify(bytes)}.toString()) {
    throw StateError('Incorrect encoded bytes for case ${index}: ' + encoded${index}.toString());
  }
  final decoded${index} = ${rendered.decoder.content}.decode(Uint8List.fromList(${JSON.stringify(bytes)}));
  if (decoded${index}.toString() != (${value}).toString()) {
    throw StateError('Incorrect decoded value for case ${index}');
  }`;
    });
    const file = join(directory, "prefixes.dart");
    const packageConfig = resolve(__dirname, "../../../.dart_tool/package_config.json");

    try {
      writeFileSync(file, `${[...imports].map((uri) => `import '${uri}';`).join("\n")}\nvoid main() {${checks.join("\n")}\n}\n`);
      const result = spawnSync("dart", [`--packages=${packageConfig}`, file], {
        encoding: "utf8",
        timeout: 30_000,
      });
      expect(result.error).toBeUndefined();
      expect(result.stderr).toBe("");
      expect(result.status).toBe(0);
    } finally {
      rmSync(directory, { recursive: true, force: true });
    }
  }, 40_000);
});
