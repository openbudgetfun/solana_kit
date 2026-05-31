import type { ProgramNode } from "@codama/nodes";

import type { Fragment } from "../utils/fragment.js";
import {
  emptyFragment,
  fragment,
  fragmentFromString,
  mergeFragments,
  use,
} from "../utils/fragment.js";
import type { RenderScope } from "../utils/options.js";
import { camelCase, pascalCase } from "../utils/nameTransformers.js";
import { WELL_KNOWN_ADDRESSES } from "../utils/wellKnownAddresses.js";

/**
 * Generate a full Dart file for a program.
 */
export function getProgramPageFragment(
  node: ProgramNode,
  scope: RenderScope,
): Fragment {
  const name = node.name as string;
  const addressConstName = scope.nameApi.programAddressConstant(name);

  const wellKnownName = WELL_KNOWN_ADDRESSES.get(node.publicKey);

  // For well-known addresses, export and alias the canonical constant from
  // solana_kit_addresses instead of hardcoding the address string.
  // When the generated name matches the canonical name, a simple export suffices.
  // When they differ, we also need a local const alias.
  // For unknown addresses, fall back to the original Address('...') pattern.
  const addressDeclaration: Fragment = wellKnownName
    ? addressConstName === wellKnownName
      ? fragment`// Auto-generated. Do not edit.
// ignore_for_file: type=lint

/// The address of the ${fragmentFromString(pascalCase(name))} program.
export 'package:solana_kit_addresses/solana_kit_addresses.dart' show ${fragmentFromString(wellKnownName)};`
      : fragment`${use(wellKnownName, "solanaAddresses")}

// Auto-generated. Do not edit.
// ignore_for_file: type=lint

/// The address of the ${fragmentFromString(pascalCase(name))} program.
const ${fragmentFromString(addressConstName)} = ${fragmentFromString(wellKnownName)};`
    : fragment`// Auto-generated. Do not edit.
// ignore_for_file: type=lint

${use("Address", "solanaAddresses")}

/// The address of the ${fragmentFromString(pascalCase(name))} program.
const ${fragmentFromString(addressConstName)} = Address('${fragmentFromString(node.publicKey)}');`;

  const parts: Fragment[] = [addressDeclaration];

  // Account identifier enum
  const accounts = node.accounts ?? [];
  if (accounts.length > 0) {
    const accountVariants = accounts
      .map((acc) => `  ${camelCase(acc.name as string)},`)
      .join("\n");

    parts.push(fragment`
/// Known accounts for the ${fragmentFromString(pascalCase(name))} program.
enum ${fragmentFromString(pascalCase(name))}Account {
${fragmentFromString(accountVariants)}
}`);
  }

  // Instruction identifier enum
  const instructions = node.instructions ?? [];
  if (instructions.length > 0) {
    const instrVariants = instructions
      .map((instr) => `  ${camelCase(instr.name as string)},`)
      .join("\n");

    parts.push(fragment`
/// Known instructions for the ${fragmentFromString(pascalCase(name))} program.
enum ${fragmentFromString(pascalCase(name))}Instruction {
${fragmentFromString(instrVariants)}
}`);
  }

  return mergeFragments(parts, (cs) => cs.join("\n"));
}