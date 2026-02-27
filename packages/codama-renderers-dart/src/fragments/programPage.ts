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

/**
 * Generate a full Dart file for a program.
 */
export function getProgramPageFragment(
  node: ProgramNode,
  scope: RenderScope,
): Fragment {
  const name = node.name as string;
  const addressConstName = scope.nameApi.programAddressConstant(name);

  const parts: Fragment[] = [
    fragment`// Auto-generated. Do not edit.
// ignore_for_file: type=lint

${use("Address", "solanaAddresses")}

/// The address of the ${fragmentFromString(pascalCase(name))} program.
const ${fragmentFromString(addressConstName)} = Address('${fragmentFromString(node.publicKey)}');`,
  ];

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
