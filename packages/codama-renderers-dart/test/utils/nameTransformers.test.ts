import { describe, expect, it } from "vitest";

import {
  camelCase,
  createDartNameApi,
  pascalCase,
  screamingSnakeCase,
  snakeCase,
} from "../../src/utils/nameTransformers.js";

describe("pascalCase", () => {
  it("converts snake_case to PascalCase", () => {
    expect(pascalCase("my_type_name")).toBe("MyTypeName");
  });

  it("converts camelCase to PascalCase", () => {
    expect(pascalCase("myTypeName")).toBe("MyTypeName");
  });

  it("converts kebab-case to PascalCase", () => {
    expect(pascalCase("my-type-name")).toBe("MyTypeName");
  });

  it("converts space-separated to PascalCase", () => {
    expect(pascalCase("my type name")).toBe("MyTypeName");
  });

  it("handles single word", () => {
    expect(pascalCase("hello")).toBe("Hello");
  });

  it("handles already PascalCase", () => {
    expect(pascalCase("MyTypeName")).toBe("MyTypeName");
  });

  it("handles empty string", () => {
    expect(pascalCase("")).toBe("");
  });
});

describe("camelCase", () => {
  it("converts snake_case to camelCase", () => {
    expect(camelCase("my_type_name")).toBe("myTypeName");
  });

  it("converts PascalCase to camelCase", () => {
    expect(camelCase("MyTypeName")).toBe("myTypeName");
  });

  it("converts kebab-case to camelCase", () => {
    expect(camelCase("my-type-name")).toBe("myTypeName");
  });

  it("handles single word", () => {
    expect(camelCase("hello")).toBe("hello");
  });

  it("handles already camelCase", () => {
    expect(camelCase("myTypeName")).toBe("myTypeName");
  });

  it("handles empty string", () => {
    expect(camelCase("")).toBe("");
  });
});

describe("snakeCase", () => {
  it("converts camelCase to snake_case", () => {
    expect(snakeCase("myTypeName")).toBe("my_type_name");
  });

  it("converts PascalCase to snake_case", () => {
    expect(snakeCase("MyTypeName")).toBe("my_type_name");
  });

  it("converts kebab-case to snake_case", () => {
    expect(snakeCase("my-type-name")).toBe("my_type_name");
  });

  it("converts space-separated to snake_case", () => {
    expect(snakeCase("my type name")).toBe("my_type_name");
  });

  it("handles single word", () => {
    expect(snakeCase("hello")).toBe("hello");
  });

  it("handles empty string", () => {
    expect(snakeCase("")).toBe("");
  });
});

describe("screamingSnakeCase", () => {
  it("converts camelCase to SCREAMING_SNAKE_CASE", () => {
    expect(screamingSnakeCase("myTypeName")).toBe("MY_TYPE_NAME");
  });

  it("converts PascalCase to SCREAMING_SNAKE_CASE", () => {
    expect(screamingSnakeCase("MyTypeName")).toBe("MY_TYPE_NAME");
  });

  it("converts snake_case to SCREAMING_SNAKE_CASE", () => {
    expect(screamingSnakeCase("my_type_name")).toBe("MY_TYPE_NAME");
  });

  it("handles single word", () => {
    expect(screamingSnakeCase("hello")).toBe("HELLO");
  });
});

describe("createDartNameApi", () => {
  const nameApi = createDartNameApi();

  describe("dataType", () => {
    it("converts to PascalCase", () => {
      expect(nameApi.dataType("myStruct")).toBe("MyStruct");
    });

    it("handles snake_case input", () => {
      expect(nameApi.dataType("my_struct")).toBe("MyStruct");
    });
  });

  describe("encoderFunction", () => {
    it("generates get{PascalCase}Encoder", () => {
      expect(nameApi.encoderFunction("myType")).toBe("getMyTypeEncoder");
    });
  });

  describe("decoderFunction", () => {
    it("generates get{PascalCase}Decoder", () => {
      expect(nameApi.decoderFunction("myType")).toBe("getMyTypeDecoder");
    });
  });

  describe("codecFunction", () => {
    it("generates get{PascalCase}Codec", () => {
      expect(nameApi.codecFunction("myType")).toBe("getMyTypeCodec");
    });
  });

  describe("accountFetchFunction", () => {
    it("generates fetch{PascalCase}", () => {
      expect(nameApi.accountFetchFunction("tokenAccount")).toBe(
        "fetchTokenAccount",
      );
    });
  });

  describe("accountFetchMaybeFunction", () => {
    it("generates fetchMaybe{PascalCase}", () => {
      expect(nameApi.accountFetchMaybeFunction("tokenAccount")).toBe(
        "fetchMaybeTokenAccount",
      );
    });
  });

  describe("accountDecodeFunction", () => {
    it("generates decode{PascalCase}", () => {
      expect(nameApi.accountDecodeFunction("tokenAccount")).toBe(
        "decodeTokenAccount",
      );
    });
  });

  describe("accountSizeConstant", () => {
    it("generates {camelCase}Size", () => {
      expect(nameApi.accountSizeConstant("tokenAccount")).toBe(
        "tokenAccountSize",
      );
    });
  });

  describe("pdaFindFunction", () => {
    it("generates find{PascalCase}Pda", () => {
      expect(nameApi.pdaFindFunction("metadata")).toBe("findMetadataPda");
    });
  });

  describe("instructionFunction", () => {
    it("generates get{PascalCase}Instruction", () => {
      expect(nameApi.instructionFunction("transfer")).toBe(
        "getTransferInstruction",
      );
    });
  });

  describe("instructionParseFunction", () => {
    it("generates parse{PascalCase}Instruction", () => {
      expect(nameApi.instructionParseFunction("transfer")).toBe(
        "parseTransferInstruction",
      );
    });
  });

  describe("programAddressConstant", () => {
    it("generates {camelCase}ProgramAddress", () => {
      expect(nameApi.programAddressConstant("tokenMetadata")).toBe(
        "tokenMetadataProgramAddress",
      );
    });
  });

  describe("errorConstant", () => {
    it("generates {camelCase(program)}Error{PascalCase(error)}", () => {
      expect(nameApi.errorConstant("myProgram", "invalidOwner")).toBe(
        "myProgramErrorInvalidOwner",
      );
    });
  });

  describe("errorMessageFunction", () => {
    it("generates get{PascalCase}ErrorMessage", () => {
      expect(nameApi.errorMessageFunction("myProgram")).toBe(
        "getMyProgramErrorMessage",
      );
    });
  });

  describe("enumVariant", () => {
    it("converts to camelCase", () => {
      expect(nameApi.enumVariant("MyVariant")).toBe("myVariant");
    });
  });

  describe("sealedClassVariant", () => {
    it("converts variant name to PascalCase", () => {
      expect(nameApi.sealedClassVariant("MyEnum", "someVariant")).toBe(
        "SomeVariant",
      );
    });
  });

  describe("fileName", () => {
    it("converts to snake_case", () => {
      expect(nameApi.fileName("MyTypeName")).toBe("my_type_name");
    });
  });

  describe("discriminatorConstant", () => {
    it("generates {camelCase}Discriminator", () => {
      expect(nameApi.discriminatorConstant("transfer")).toBe(
        "transferDiscriminator",
      );
    });
  });

  describe("isTypeFunction", () => {
    it("generates is{PascalCase}", () => {
      expect(nameApi.isTypeFunction("myType")).toBe("isMyType");
    });
  });
});
