import {
  getAllInstructionsWithSubs,
  type InstructionNode,
  type ProgramNode,
  type ValueNode,
} from "@codama/nodes";
import { visit } from "@codama/visitors-core";

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
import { toDartStringLiteral } from "../utils/valueNodes.js";
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
const ${fragmentFromString(addressConstName)} = Address(${fragmentFromString(toDartStringLiteral(node.publicKey))});`;

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

  // Instruction identification and parsing helpers.
  const instructions = getAllInstructionsWithSubs(node);
  if (instructions.length > 0) {
    const programName = pascalCase(name);
    const instructionEnum = `${programName}Instruction`;
    const instrVariants = instructions
      .map((instr) => `  ${camelCase(instr.name as string)},`)
      .join("\n");

    parts.push(fragment`
/// Known instructions for the ${fragmentFromString(programName)} program.
enum ${fragmentFromString(instructionEnum)} {
${fragmentFromString(instrVariants)}
}`);

    const identifiableInstructions = instructions
      .map((instruction) => ({
        instruction,
        condition: getInstructionDiscriminatorCondition(instruction, scope),
      }))
      .filter(({ condition }) => condition !== null) as {
        instruction: InstructionNode;
        condition: Fragment;
      }[];

    if (identifiableInstructions.length > 0) {
      const identifyBranches = identifiableInstructions.map(
        ({ instruction, condition }) => fragment`  if (${condition}) {
    return ${fragmentFromString(instructionEnum)}.${fragmentFromString(camelCase(instruction.name as string))};
  }`,
      );
      const parsedBase = `Parsed${programName}Instruction`;
      const parsedClasses = instructions.map((instruction) => {
        const instructionName = pascalCase(instruction.name as string);
        const variant = camelCase(instruction.name as string);
        const parsedClass = `Parsed${instructionName}`;
        const dataClass = `${instructionName}InstructionData`;
        return fragment`/// A parsed ${fragmentFromString(instructionName)} instruction.
final class ${fragmentFromString(parsedClass)} extends ${fragmentFromString(parsedBase)} {
  const ${fragmentFromString(parsedClass)}({required this.data})
      : super(${fragmentFromString(instructionEnum)}.${fragmentFromString(variant)});

  final ${use(dataClass, "../instructions/instructions.dart")} data;
}`;
      });
      const parseBranches = instructions.map((instruction) => {
        const instructionName = pascalCase(instruction.name as string);
        const variant = camelCase(instruction.name as string);
        const parsedClass = `Parsed${instructionName}`;
        const parseFunction = scope.nameApi.instructionParseFunction(
          instruction.name as string,
        );
        return fragment`    ${fragmentFromString(instructionEnum)}.${fragmentFromString(variant)} => ${fragmentFromString(parsedClass)}(
      data: ${use(parseFunction, "../instructions/instructions.dart")}(instruction),
    ),`;
      });

      parts.push(fragment`
/// Identifies the type of a ${fragmentFromString(programName)} instruction.
${fragmentFromString(instructionEnum)} identify${fragmentFromString(programName)}Instruction(
  ${use("Uint8List", "dartTypedData")} data,
) {
${mergeFragments(identifyBranches, (cs) => cs.join("\n"))}

  throw ${use("SolanaError", "solanaErrors")}(
    ${use("SolanaErrorCode", "solanaErrors")}.programClientsFailedToIdentifyInstruction,
    {
      'instructionData': data,
      'programName': '${fragmentFromString(name)}',
    },
  );
}

/// A parsed instruction from the ${fragmentFromString(programName)} program.
sealed class ${fragmentFromString(parsedBase)} {
  const ${fragmentFromString(parsedBase)}(this.instructionType);

  final ${fragmentFromString(instructionEnum)} instructionType;
}

${mergeFragments(parsedClasses, (cs) => cs.join("\n\n"))}

/// Parses a ${fragmentFromString(programName)} instruction.
${fragmentFromString(parsedBase)} parse${fragmentFromString(programName)}Instruction(
  ${use("Instruction", "solanaInstructions")} instruction,
) {
  return switch (identify${fragmentFromString(programName)}Instruction(
    instruction.data ?? Uint8List(0),
  )) {
${mergeFragments(parseBranches, (cs) => cs.join("\n"))}
  };
}`);
    }
  }

  return mergeFragments(parts, (cs) => cs.join("\n"));
}

function getInstructionDiscriminatorCondition(
  instruction: InstructionNode,
  scope: RenderScope,
): Fragment | null {
  const discriminators = instruction.discriminators ?? [];
  if (discriminators.length === 0) return null;

  const conditions = discriminators.map((discriminator): Fragment | null => {
    switch (discriminator.kind) {
      case "sizeDiscriminatorNode":
        return fragment`data.length == ${discriminator.size}`;
      case "constantDiscriminatorNode": {
        const manifest = visit(
          discriminator.constant.type,
          scope.typeManifestVisitor,
        );
        const value = getValueFragment(
          discriminator.constant.value,
          manifest.type.content,
        );
        if (value === null) return null;
        return fragment`${use("containsBytes", "solanaCodecsCore")}(data, ${manifest.encoder}.encode(${value}), ${discriminator.offset})`;
      }
      case "fieldDiscriminatorNode": {
        const argument = (instruction.arguments ?? []).find(
          (candidate) => candidate.name === discriminator.name,
        );
        if (argument?.defaultValue == null) return null;
        const manifest = visit(argument.type, scope.typeManifestVisitor);
        const value = getValueFragment(
          argument.defaultValue,
          manifest.type.content,
        );
        if (value === null) return null;
        return fragment`${use("containsBytes", "solanaCodecsCore")}(data, ${manifest.encoder}.encode(${value}), ${discriminator.offset})`;
      }
    }
  });

  if (conditions.some((condition) => condition === null)) return null;
  return mergeFragments(conditions as Fragment[], (cs) => cs.join(" && "));
}

function getValueFragment(
  value:
    | ValueNode
    | NonNullable<
        NonNullable<InstructionNode["arguments"]>[number]["defaultValue"]
      >,
  dartType?: string,
): Fragment | null {
  switch (value.kind) {
    case "numberValueNode":
      return fragmentFromString(
        dartType === "BigInt"
          ? `BigInt.from(${value.number})`
          : String(value.number),
      );
    case "booleanValueNode":
      return fragmentFromString(String(value.boolean));
    case "stringValueNode":
      return fragmentFromString(toDartStringLiteral(value.string));
    case "bytesValueNode": {
      const clean = value.data.replace(/^0x/, "");
      const bytes = clean.match(/.{1,2}/g)?.map((byte) => parseInt(byte, 16)) ?? [];
      return fragment`${use("Uint8List", "dartTypedData")}.fromList([${fragmentFromString(bytes.join(", "))}])`;
    }
    default:
      return null;
  }
}
