/**
 * Maps logical module names to Dart package: URIs.
 */
export const DART_EXTERNAL_PACKAGE_MAP: Record<string, string> = {
  // Dart core
  dartTypedData: "dart:typed_data",
  dartConvert: "dart:convert",
  meta: "package:meta/meta.dart",

  // solana_kit packages
  solanaAddresses: "package:solana_kit_addresses/solana_kit_addresses.dart",
  solanaCodecsCore: "package:solana_kit_codecs_core/solana_kit_codecs_core.dart",
  solanaCodecsDataStructures:
    "package:solana_kit_codecs_data_structures/solana_kit_codecs_data_structures.dart",
  solanaCodecsNumbers:
    "package:solana_kit_codecs_numbers/solana_kit_codecs_numbers.dart",
  solanaCodecsStrings:
    "package:solana_kit_codecs_strings/solana_kit_codecs_strings.dart",
  solanaErrors: "package:solana_kit_errors/solana_kit_errors.dart",
  solanaAccounts: "package:solana_kit_accounts/solana_kit_accounts.dart",
  solanaInstructions:
    "package:solana_kit_instructions/solana_kit_instructions.dart",
  solanaPrograms: "package:solana_kit_programs/solana_kit_programs.dart",
  solanaRpcTypes: "package:solana_kit_rpc_types/solana_kit_rpc_types.dart",
  solanaSigners: "package:solana_kit_signers/solana_kit_signers.dart",
};

/**
 * Tracks Dart import URIs needed by generated code.
 *
 * Dart imports entire libraries (not individual symbols), so we only
 * need to track which package URIs are used, not specific symbols.
 */
export class DartImportMap {
  private _imports = new Set<string>();

  /**
   * Add a logical module name (resolved via DART_EXTERNAL_PACKAGE_MAP)
   * or a raw Dart import URI.
   */
  add(module: string): this {
    this._imports.add(module);
    return this;
  }

  /**
   * Merge another DartImportMap into this one.
   */
  mergeWith(other: DartImportMap): this {
    for (const imp of other._imports) {
      this._imports.add(imp);
    }
    return this;
  }

  /**
   * Check if this import map is empty.
   */
  get isEmpty(): boolean {
    return this._imports.size === 0;
  }

  /**
   * Get all raw module keys.
   */
  get modules(): Set<string> {
    return new Set(this._imports);
  }

  /**
   * Resolve all imports to Dart import URIs and return them sorted.
   * @param internalMap Maps logical names to relative file paths for generated code cross-references.
   */
  resolve(internalMap: Record<string, string> = {}): string[] {
    const uris = new Set<string>();

    for (const module of this._imports) {
      // Check internal map first (generated cross-references)
      if (module in internalMap) {
        uris.add(internalMap[module]);
      }
      // Then external package map
      else if (module in DART_EXTERNAL_PACKAGE_MAP) {
        uris.add(DART_EXTERNAL_PACKAGE_MAP[module]);
      }
      // Assume it's already a raw URI (e.g., "package:..." or relative path)
      else {
        uris.add(module);
      }
    }

    // Sort: dart: first, then package:, then relative
    return [...uris].sort((a, b) => {
      const aWeight = a.startsWith("dart:") ? 0 : a.startsWith("package:") ? 1 : 2;
      const bWeight = b.startsWith("dart:") ? 0 : b.startsWith("package:") ? 1 : 2;
      if (aWeight !== bWeight) return aWeight - bWeight;
      return a.localeCompare(b);
    });
  }

  /**
   * Render all imports as Dart import statements.
   */
  toString(internalMap: Record<string, string> = {}): string {
    const resolved = this.resolve(internalMap);
    if (resolved.length === 0) return "";

    const lines: string[] = [];
    let lastPrefix = "";

    for (const uri of resolved) {
      const prefix = uri.startsWith("dart:")
        ? "dart"
        : uri.startsWith("package:")
          ? "package"
          : "relative";

      // Add blank line between groups
      if (lastPrefix && lastPrefix !== prefix) {
        lines.push("");
      }
      lastPrefix = prefix;

      lines.push(`import '${uri}';`);
    }

    return lines.join("\n");
  }
}
