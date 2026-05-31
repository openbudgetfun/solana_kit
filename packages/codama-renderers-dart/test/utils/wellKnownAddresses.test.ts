import { describe, expect, it } from "vitest";

import { WELL_KNOWN_ADDRESSES } from "../../src/utils/wellKnownAddresses.js";

describe("WELL_KNOWN_ADDRESSES", () => {
  it("contains system program address", () => {
    expect(WELL_KNOWN_ADDRESSES.get("11111111111111111111111111111111")).toBe(
      "systemProgramAddress",
    );
  });

  it("contains compute budget program address", () => {
    expect(
      WELL_KNOWN_ADDRESSES.get("ComputeBudget111111111111111111111111111111"),
    ).toBe("computeBudgetProgramAddress");
  });

  it("contains token program address", () => {
    expect(
      WELL_KNOWN_ADDRESSES.get("TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"),
    ).toBe("tokenProgramAddress");
  });

  it("contains stake program address", () => {
    expect(
      WELL_KNOWN_ADDRESSES.get("Stake11111111111111111111111111111111111111"),
    ).toBe("stakeProgramAddress");
  });

  it("returns undefined for unknown addresses", () => {
    expect(
      WELL_KNOWN_ADDRESSES.get("UnknownProgram1111111111111111111111111"),
    ).toBeUndefined();
  });

  it("maps all sysvar addresses", () => {
    expect(
      WELL_KNOWN_ADDRESSES.get("SysvarC1ock11111111111111111111111111111111"),
    ).toBe("sysvarClockAddress");
    expect(
      WELL_KNOWN_ADDRESSES.get("Rent11111111111111111111111111111111111111"),
    ).toBe("sysvarRentAddress");
    expect(
      WELL_KNOWN_ADDRESSES.get("Sysvar1nstruct1ons11111111111111111111111111"),
    ).toBe("sysvarInstructionsAddress");
  });

  it("maps SPL addresses", () => {
    expect(
      WELL_KNOWN_ADDRESSES.get("TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA"),
    ).toBe("tokenProgramAddress");
    expect(
      WELL_KNOWN_ADDRESSES.get("TokenzQdBNb4qyze1S1U9AHB8MGXmNK1REkTPT5Z3Y"),
    ).toBe("token2022ProgramAddress");
  });
});