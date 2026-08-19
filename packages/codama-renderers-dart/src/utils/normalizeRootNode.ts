import type { RootNode } from "@codama/nodes";

/**
 * Normalizes a serialized Codama root before it reaches Codama's visitors.
 *
 * Codama constructors materialize empty child collections, while generated
 * JSON commonly omits them. Pina intentionally omits those empty fields, so
 * restore only the structural defaults required by Codama traversal. This is
 * a copy: callers retain their original parsed IDL unchanged.
 */
export function normalizeRootNode(root: RootNode): RootNode {
  return normalizeNode(root) as RootNode;
}

function normalizeNode(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map(normalizeNode);
  }

  if (!isRecord(value)) {
    return value;
  }

  const normalized = Object.fromEntries(
    Object.entries(value).map(([key, child]) => [key, normalizeNode(child)]),
  ) as Record<string, unknown>;

  switch (normalized.kind) {
    case "rootNode":
      setEmptyCollection(normalized, "additionalPrograms");
      break;
    case "programNode":
      setEmptyCollection(normalized, "accounts");
      setEmptyCollection(normalized, "constants");
      setEmptyCollection(normalized, "definedTypes");
      setEmptyCollection(normalized, "errors");
      setEmptyCollection(normalized, "events");
      setEmptyCollection(normalized, "instructions");
      setEmptyCollection(normalized, "pdas");
      break;
    case "instructionNode":
      setEmptyCollection(normalized, "accounts");
      setEmptyCollection(normalized, "arguments");
      break;
    case "pdaNode":
      setEmptyCollection(normalized, "seeds");
      break;
    case "structTypeNode":
      setEmptyCollection(normalized, "fields");
      break;
    case "enumTypeNode":
      setEmptyCollection(normalized, "variants");
      break;
    case "tupleTypeNode":
      setEmptyCollection(normalized, "items");
      break;
    case "hiddenPrefixTypeNode":
      setEmptyCollection(normalized, "prefix");
      break;
    case "hiddenSuffixTypeNode":
      setEmptyCollection(normalized, "suffix");
      break;
  }

  return normalized;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function setEmptyCollection(record: Record<string, unknown>, key: string): void {
  if (record[key] === undefined) {
    record[key] = [];
  }
}
