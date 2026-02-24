import type { CamelCaseString } from "@codama/nodes";

/**
 * Naming convention transformers for Dart code generation.
 */

/** Convert a string to PascalCase */
export function pascalCase(str: string): string {
  return str
    .replace(/[-_\s]+(.)?/g, (_, c) => (c ? c.toUpperCase() : ""))
    .replace(/^(.)/, (c) => c.toUpperCase());
}

/** Convert a string to camelCase */
export function camelCase(str: string): string {
  const pascal = pascalCase(str);
  return pascal.charAt(0).toLowerCase() + pascal.slice(1);
}

/** Convert a string to snake_case */
export function snakeCase(str: string): string {
  return str
    .replace(/([A-Z])/g, "_$1")
    .replace(/[-\s]+/g, "_")
    .replace(/^_/, "")
    .replace(/_+/g, "_")
    .toLowerCase();
}

/** Convert a string to SCREAMING_SNAKE_CASE */
export function screamingSnakeCase(str: string): string {
  return snakeCase(str).toUpperCase();
}

/**
 * All name transformation functions for Dart code generation.
 */
export interface DartNameApi {
  /** Data class name: `PascalCase` */
  dataType(name: string): string;
  /** Encoder function name: `get{PascalCase}Encoder` */
  encoderFunction(name: string): string;
  /** Decoder function name: `get{PascalCase}Decoder` */
  decoderFunction(name: string): string;
  /** Codec function name: `get{PascalCase}Codec` */
  codecFunction(name: string): string;
  /** Account fetch function: `fetch{PascalCase}` */
  accountFetchFunction(name: string): string;
  /** Account fetch maybe function: `fetchMaybe{PascalCase}` */
  accountFetchMaybeFunction(name: string): string;
  /** Account decode function: `decode{PascalCase}` */
  accountDecodeFunction(name: string): string;
  /** Account size constant: `{camelCase}Size` */
  accountSizeConstant(name: string): string;
  /** PDA finder function: `find{PascalCase}Pda` */
  pdaFindFunction(name: string): string;
  /** Instruction builder function: `get{PascalCase}Instruction` */
  instructionFunction(name: string): string;
  /** Instruction parse function: `parse{PascalCase}Instruction` */
  instructionParseFunction(name: string): string;
  /** Program address constant: `{camelCase}ProgramAddress` */
  programAddressConstant(name: string): string;
  /** Error code constant: `{programName}Error{PascalCase}` */
  errorConstant(programName: string, errorName: string): string;
  /** Error message function: `get{PascalCase}ErrorMessage` */
  errorMessageFunction(name: string): string;
  /** Enum variant: `camelCase` */
  enumVariant(name: string): string;
  /** Sealed class variant (data enum): `PascalCase` */
  sealedClassVariant(parentName: string, variantName: string): string;
  /** File name: `snake_case.dart` */
  fileName(name: string): string;
  /** Discriminator constant: `{camelCase}Discriminator` */
  discriminatorConstant(name: string): string;
  /** isX() helper for type check: `is{PascalCase}` */
  isTypeFunction(name: string): string;
}

/**
 * Create the default Dart name API.
 */
export function createDartNameApi(): DartNameApi {
  return {
    dataType: (name) => pascalCase(name),
    encoderFunction: (name) => `get${pascalCase(name)}Encoder`,
    decoderFunction: (name) => `get${pascalCase(name)}Decoder`,
    codecFunction: (name) => `get${pascalCase(name)}Codec`,
    accountFetchFunction: (name) => `fetch${pascalCase(name)}`,
    accountFetchMaybeFunction: (name) => `fetchMaybe${pascalCase(name)}`,
    accountDecodeFunction: (name) => `decode${pascalCase(name)}`,
    accountSizeConstant: (name) => `${camelCase(name)}Size`,
    pdaFindFunction: (name) => `find${pascalCase(name)}Pda`,
    instructionFunction: (name) => `get${pascalCase(name)}Instruction`,
    instructionParseFunction: (name) => `parse${pascalCase(name)}Instruction`,
    programAddressConstant: (name) => `${camelCase(name)}ProgramAddress`,
    errorConstant: (programName, errorName) =>
      `${camelCase(programName)}Error${pascalCase(errorName)}`,
    errorMessageFunction: (name) => `get${pascalCase(name)}ErrorMessage`,
    enumVariant: (name) => camelCase(name),
    sealedClassVariant: (_parentName, variantName) => pascalCase(variantName),
    isTypeFunction: (name) => `is${pascalCase(name)}`,
    fileName: (name) => snakeCase(name),
    discriminatorConstant: (name) => `${camelCase(name)}Discriminator`,
  };
}

/**
 * Convert a CamelCaseString to a regular string.
 */
export function fromCamelCaseString(str: CamelCaseString): string {
  return str as string;
}
