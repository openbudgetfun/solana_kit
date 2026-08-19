import type {
  AccountNode,
  ConstantValueNode,
  InstructionNode,
  StructFieldTypeNode,
} from "@codama/nodes";
import { resolveNestedTypeNode } from "@codama/nodes";
import { visit } from "@codama/visitors-core";

import type { Fragment } from "./fragment.js";
import {
  emptyFragment,
  fragment,
  fragmentFromString,
  mergeFragments,
  use,
} from "./fragment.js";
import type { RenderScope } from "./options.js";
import { getDartValueFragment } from "./valueNodes.js";

type DiscriminatedNode = AccountNode | InstructionNode;

/**
 * Generate decoder guards for every discriminator declared by a Codama node.
 */
export function getDiscriminatorValidationFragment(
  node: DiscriminatedNode,
  scope: RenderScope,
): Fragment {
  const discriminators = node.discriminators ?? [];
  if (discriminators.length === 0) return emptyFragment();

  const fields = getDiscriminatorFields(node);
  const fragments = discriminators.map((discriminator): Fragment => {
    switch (discriminator.kind) {
      case "constantDiscriminatorNode":
        return getConstantValidationFragment(
          discriminator.constant,
          discriminator.offset,
          scope,
        );
      case "fieldDiscriminatorNode": {
        const field = fields.find(
          (candidate) => candidate.name === discriminator.name,
        );
        if (field?.defaultValue == null) {
          throw new Error(
            `Field discriminator "${discriminator.name}" on ${node.kind} "${node.name}" must reference a field with a default value.`,
          );
        }
        return getConstantValidationFragment(
          {
            kind: "constantValueNode",
            type: field.type,
            value: field.defaultValue,
          } as ConstantValueNode,
          discriminator.offset,
          scope,
        );
      }
      case "sizeDiscriminatorNode": {
        if (
          !Number.isSafeInteger(discriminator.size) ||
          discriminator.size < 0
        ) {
          throw new Error(
            `Discriminator size must be a non-negative safe integer, got ${discriminator.size}.`,
          );
        }
        return fragment`if (bytes.length - offset != ${fragmentFromString(String(discriminator.size))}) {
  throw ${use("SolanaError", "solanaErrors")}(
    ${use("SolanaErrorCode", "solanaErrors")}.codecsInvalidByteLength,
    {
      'codecDescription': '${fragmentFromString(node.name as string)} discriminator',
      'expected': ${fragmentFromString(String(discriminator.size))},
      'bytesLength': bytes.length - offset,
    },
  );
}`;
      }
    }
  });

  return mergeFragments(fragments, (contents) => contents.join("\n"));
}

function getConstantValidationFragment(
  constant: ConstantValueNode,
  discriminatorOffset: number,
  scope: RenderScope,
): Fragment {
  if (!Number.isSafeInteger(discriminatorOffset) || discriminatorOffset < 0) {
    throw new Error(
      `Discriminator offset must be a non-negative safe integer, got ${discriminatorOffset}.`,
    );
  }

  const manifest = visit(constant.type, scope.typeManifestVisitor);
  const value = getDartValueFragment(
    constant.value,
    manifest.type.content,
  );
  return fragment`${use("getConstantDecoder", "solanaCodecsDataStructures")}(
  ${manifest.encoder}.encode(${value}),
).read(bytes, offset + ${fragmentFromString(String(discriminatorOffset))});`;
}

function getDiscriminatorFields(
  node: DiscriminatedNode,
): readonly StructFieldTypeNode[] {
  if (node.kind === "accountNode") {
    return resolveNestedTypeNode(node.data).fields ?? [];
  }
  return (node.arguments ?? []).map(
    (argument) =>
      ({
        ...argument,
        kind: "structFieldTypeNode",
      }) as StructFieldTypeNode,
  );
}
