import { describe, expect, it } from "vitest";

import {
  bytesToDartHexList,
  bytesToDartUint8List,
} from "../../src/utils/codecs.js";

describe("bytesToDartHexList", () => {
  it("converts an empty array to []", () => {
    const bytes = new Uint8Array([]);
    expect(bytesToDartHexList(bytes)).toBe("[]");
  });

  it("converts a single byte", () => {
    const bytes = new Uint8Array([0xff]);
    expect(bytesToDartHexList(bytes)).toBe("[0xff]");
  });

  it("pads single-digit hex values with zero", () => {
    const bytes = new Uint8Array([0x01, 0x0a]);
    expect(bytesToDartHexList(bytes)).toBe("[0x01, 0x0a]");
  });

  it("converts multiple bytes", () => {
    const bytes = new Uint8Array([0xde, 0xad, 0xbe, 0xef]);
    expect(bytesToDartHexList(bytes)).toBe("[0xde, 0xad, 0xbe, 0xef]");
  });

  it("handles zero byte", () => {
    const bytes = new Uint8Array([0x00]);
    expect(bytesToDartHexList(bytes)).toBe("[0x00]");
  });

  it("handles typical 8-byte discriminator", () => {
    const bytes = new Uint8Array([0xf0, 0x9f, 0xa5, 0xb3, 0x12, 0x34, 0x56, 0x78]);
    expect(bytesToDartHexList(bytes)).toBe(
      "[0xf0, 0x9f, 0xa5, 0xb3, 0x12, 0x34, 0x56, 0x78]",
    );
  });
});

describe("bytesToDartUint8List", () => {
  it("wraps hex list in Uint8List.fromList()", () => {
    const bytes = new Uint8Array([0xde, 0xad]);
    expect(bytesToDartUint8List(bytes)).toBe(
      "Uint8List.fromList([0xde, 0xad])",
    );
  });

  it("handles empty array", () => {
    const bytes = new Uint8Array([]);
    expect(bytesToDartUint8List(bytes)).toBe("Uint8List.fromList([])");
  });

  it("handles single byte", () => {
    const bytes = new Uint8Array([0x42]);
    expect(bytesToDartUint8List(bytes)).toBe("Uint8List.fromList([0x42])");
  });
});
