import type {
  AccountNode,
  ConstantDiscriminatorNode,
  FieldDiscriminatorNode,
  InstructionNode,
  SizeDiscriminatorNode,
} from "@codama/nodes";
import { visit } from "@codama/visitors-core";

import type { Fragment } from "../utils/fragment.js";
import { emptyFragment, fragment, fragmentFromString, mergeFragments, use } from "../utils/fragment.js";
import type { RenderScope } from "../utils/options.js";
import { bytesToDartHexList } from "../utils/codecs.js";

/**
 * Generate discriminator constant declarations for an account or instruction.
 */
export function getDiscriminatorConstantsFragment(
  node: AccountNode | InstructionNode,
  scope: RenderScope,
): Fragment {
  const discriminators = node.discriminators ?? [];
  if (discriminators.length === 0) return emptyFragment();

  const name = node.name as string;
  const constName = scope.nameApi.discriminatorConstant(name);

  const fragments: Fragment[] = [];

  for (const disc of discriminators) {
    switch (disc.kind) {
      case "constantDiscriminatorNode": {
        const constDisc = disc as ConstantDiscriminatorNode;
        if (constDisc.constant.value.kind === "bytesValueNode") {
          const bytes = hexToBytes(constDisc.constant.value.data);
          const hexList = bytesToDartHexList(bytes);
          fragments.push(
            fragment`/// The discriminator bytes for this ${node.kind === "accountNode" ? "account" : "instruction"}.
final ${constName} = ${use("Uint8List", "dartTypedData")}.fromList(${fragmentFromString(hexList)});`,
          );
        }
        break;
      }
      case "fieldDiscriminatorNode": {
        const fieldDisc = disc as FieldDiscriminatorNode;
        fragments.push(
          fragment`/// The discriminator field name: '${fragmentFromString(fieldDisc.name as string)}'.
/// Offset: ${fragmentFromString(String(fieldDisc.offset))}.`,
        );
        break;
      }
      case "sizeDiscriminatorNode": {
        const sizeDisc = disc as SizeDiscriminatorNode;
        fragments.push(
          fragment`/// This ${node.kind === "accountNode" ? "account" : "instruction"} has a size discriminator of ${fragmentFromString(String(sizeDisc.size))} bytes.`,
        );
        break;
      }
    }
  }

  if (fragments.length === 0) return emptyFragment();

  return mergeFragments(fragments, (cs) => cs.join("\n\n"));
}

function hexToBytes(hex: string): Uint8Array {
  const clean = hex.replace(/^0x/, "");
  const bytes = new Uint8Array(clean.length / 2);
  for (let i = 0; i < clean.length; i += 2) {
    bytes[i / 2] = parseInt(clean.slice(i, i + 2), 16);
  }
  return bytes;
}
