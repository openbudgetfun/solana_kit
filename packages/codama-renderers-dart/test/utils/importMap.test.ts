import { describe, expect, it } from "vitest";

import {
  DART_EXTERNAL_PACKAGE_MAP,
  DartImportMap,
} from "../../src/utils/importMap.js";

describe("DartImportMap", () => {
  describe("add", () => {
    it("adds a module key", () => {
      const map = new DartImportMap();
      map.add("solanaAddresses");
      expect(map.modules.has("solanaAddresses")).toBe(true);
    });

    it("returns this for chaining", () => {
      const map = new DartImportMap();
      const result = map.add("solanaAddresses");
      expect(result).toBe(map);
    });

    it("does not add duplicates", () => {
      const map = new DartImportMap();
      map.add("solanaAddresses");
      map.add("solanaAddresses");
      expect(map.modules.size).toBe(1);
    });

    it("can add raw URIs", () => {
      const map = new DartImportMap();
      map.add("package:custom/custom.dart");
      expect(map.modules.has("package:custom/custom.dart")).toBe(true);
    });
  });

  describe("mergeWith", () => {
    it("merges another import map into this one", () => {
      const map1 = new DartImportMap();
      map1.add("solanaAddresses");

      const map2 = new DartImportMap();
      map2.add("solanaCodecsCore");

      map1.mergeWith(map2);
      expect(map1.modules.has("solanaAddresses")).toBe(true);
      expect(map1.modules.has("solanaCodecsCore")).toBe(true);
    });

    it("returns this for chaining", () => {
      const map1 = new DartImportMap();
      const map2 = new DartImportMap();
      const result = map1.mergeWith(map2);
      expect(result).toBe(map1);
    });

    it("deduplicates when merging", () => {
      const map1 = new DartImportMap();
      map1.add("dartTypedData");

      const map2 = new DartImportMap();
      map2.add("dartTypedData");

      map1.mergeWith(map2);
      expect(map1.modules.size).toBe(1);
    });
  });

  describe("isEmpty", () => {
    it("returns true for a new import map", () => {
      const map = new DartImportMap();
      expect(map.isEmpty).toBe(true);
    });

    it("returns false after adding a module", () => {
      const map = new DartImportMap();
      map.add("solanaAddresses");
      expect(map.isEmpty).toBe(false);
    });
  });

  describe("modules", () => {
    it("returns a copy of the internal set", () => {
      const map = new DartImportMap();
      map.add("solanaAddresses");
      const modules = map.modules;
      modules.add("extra");
      // Original should not be affected
      expect(map.modules.has("extra")).toBe(false);
    });
  });

  describe("resolve", () => {
    it("resolves known module keys to Dart URIs", () => {
      const map = new DartImportMap();
      map.add("solanaAddresses");
      const resolved = map.resolve();
      expect(resolved).toContain(
        "package:solana_kit_addresses/solana_kit_addresses.dart",
      );
    });

    it("resolves dart: imports", () => {
      const map = new DartImportMap();
      map.add("dartTypedData");
      const resolved = map.resolve();
      expect(resolved).toContain("dart:typed_data");
    });

    it("passes through raw URIs unchanged", () => {
      const map = new DartImportMap();
      map.add("package:custom_lib/custom_lib.dart");
      const resolved = map.resolve();
      expect(resolved).toContain("package:custom_lib/custom_lib.dart");
    });

    it("uses internal map for cross-references", () => {
      const map = new DartImportMap();
      map.add("myLocalType");
      const resolved = map.resolve({
        myLocalType: "types/my_local_type.dart",
      });
      expect(resolved).toContain("types/my_local_type.dart");
    });

    it("internal map takes precedence over external map", () => {
      const map = new DartImportMap();
      map.add("solanaAddresses");
      const resolved = map.resolve({
        solanaAddresses: "local/addresses.dart",
      });
      expect(resolved).toContain("local/addresses.dart");
      expect(resolved).not.toContain(
        DART_EXTERNAL_PACKAGE_MAP.solanaAddresses,
      );
    });

    it("sorts dart: before package: before relative", () => {
      const map = new DartImportMap();
      map.add("package:beta/beta.dart");
      map.add("dartTypedData");
      map.add("relative/path.dart");
      map.add("solanaAddresses");

      const resolved = map.resolve({
        "relative/path.dart": "relative/path.dart",
      });

      // dart: should be first
      const dartIdx = resolved.findIndex((r) => r.startsWith("dart:"));
      const packageIdx = resolved.findIndex((r) => r.startsWith("package:"));
      const relativeIdx = resolved.findIndex((r) =>
        r.startsWith("relative/"),
      );

      expect(dartIdx).toBeLessThan(packageIdx);
      expect(packageIdx).toBeLessThan(relativeIdx);
    });

    it("sorts alphabetically within same category", () => {
      const map = new DartImportMap();
      map.add("package:zzz/zzz.dart");
      map.add("package:aaa/aaa.dart");
      const resolved = map.resolve();
      expect(resolved[0]).toBe("package:aaa/aaa.dart");
      expect(resolved[1]).toBe("package:zzz/zzz.dart");
    });
  });

  describe("toString", () => {
    it("returns empty string when no imports", () => {
      const map = new DartImportMap();
      expect(map.toString()).toBe("");
    });

    it("generates Dart import statements", () => {
      const map = new DartImportMap();
      map.add("dartTypedData");
      const result = map.toString();
      expect(result).toBe("import 'dart:typed_data';");
    });

    it("adds blank lines between different import groups", () => {
      const map = new DartImportMap();
      map.add("dartTypedData");
      map.add("solanaAddresses");
      const result = map.toString();
      const lines = result.split("\n");
      // Should have: dart import, blank line, package import
      expect(lines[0]).toBe("import 'dart:typed_data';");
      expect(lines[1]).toBe("");
      expect(lines[2]).toContain("import 'package:");
    });

    it("passes internalMap to resolve", () => {
      const map = new DartImportMap();
      map.add("myModule");
      const result = map.toString({ myModule: "types/my_module.dart" });
      expect(result).toBe("import 'types/my_module.dart';");
    });

    it("handles multiple imports in the same group", () => {
      const map = new DartImportMap();
      map.add("solanaAddresses");
      map.add("solanaCodecsCore");
      const result = map.toString();
      const lines = result.split("\n").filter((l) => l.length > 0);
      expect(lines.length).toBe(2);
      for (const line of lines) {
        expect(line).toMatch(/^import 'package:solana_kit_/);
      }
    });
  });
});

describe("DART_EXTERNAL_PACKAGE_MAP", () => {
  it("maps dartTypedData to dart:typed_data", () => {
    expect(DART_EXTERNAL_PACKAGE_MAP.dartTypedData).toBe("dart:typed_data");
  });

  it("maps dartConvert to dart:convert", () => {
    expect(DART_EXTERNAL_PACKAGE_MAP.dartConvert).toBe("dart:convert");
  });

  it("maps meta to package:meta/meta.dart", () => {
    expect(DART_EXTERNAL_PACKAGE_MAP.meta).toBe("package:meta/meta.dart");
  });

  it("maps solanaAddresses correctly", () => {
    expect(DART_EXTERNAL_PACKAGE_MAP.solanaAddresses).toBe(
      "package:solana_kit_addresses/solana_kit_addresses.dart",
    );
  });

  it("maps solanaCodecsCore correctly", () => {
    expect(DART_EXTERNAL_PACKAGE_MAP.solanaCodecsCore).toBe(
      "package:solana_kit_codecs_core/solana_kit_codecs_core.dart",
    );
  });

  it("maps solanaErrors correctly", () => {
    expect(DART_EXTERNAL_PACKAGE_MAP.solanaErrors).toBe(
      "package:solana_kit_errors/solana_kit_errors.dart",
    );
  });
});
