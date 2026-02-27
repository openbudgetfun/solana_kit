import type { ErrorNode, ProgramNode } from "@codama/nodes";

import type { Fragment } from "../utils/fragment.js";
import {
  emptyFragment,
  fragment,
  fragmentFromString,
  mergeFragments,
  use,
} from "../utils/fragment.js";
import type { RenderScope } from "../utils/options.js";
import { camelCase, pascalCase, screamingSnakeCase } from "../utils/nameTransformers.js";

/**
 * Generate a full Dart file for a program's errors.
 */
export function getErrorPageFragment(
  programNode: ProgramNode,
  scope: RenderScope,
): Fragment {
  const errors = programNode.errors ?? [];
  if (errors.length === 0) return emptyFragment();

  const programName = programNode.name as string;

  // Error code constants
  const errorConstants = errors
    .map((err) => {
      const constName = scope.nameApi.errorConstant(
        programName,
        err.name as string,
      );
      const hexCode = `0x${err.code.toString(16)}`;
      const docs = err.docs?.length
        ? err.docs.map((d) => `/// ${d}`).join("\n") + "\n"
        : "";
      const message = err.message ? `/// Message: "${err.message}"\n` : "";
      return `${docs}${message}const int ${constName} = ${hexCode}; // ${err.code}`;
    })
    .join("\n\n");

  // Error message map
  const messageEntries = errors
    .map((err) => {
      const constName = scope.nameApi.errorConstant(
        programName,
        err.name as string,
      );
      const message = err.message ?? err.name as string;
      return `    ${constName}: '${escapeString(message)}',`;
    })
    .join("\n");

  const errorMessageFnName = scope.nameApi.errorMessageFunction(programName);
  const isErrorFnName = `is${pascalCase(programName)}Error`;

  return fragment`// Auto-generated. Do not edit.
// ignore_for_file: type=lint, constant_identifier_names

/// Error codes for the ${fragmentFromString(pascalCase(programName))} program.

${fragmentFromString(errorConstants)}

/// Map of error codes to human-readable messages.
const Map<int, String> _${fragmentFromString(camelCase(programName))}ErrorMessages = {
${fragmentFromString(messageEntries)}
};

/// Get the error message for a ${fragmentFromString(pascalCase(programName))} program error code.
String? ${fragmentFromString(errorMessageFnName)}(int code) {
  return _${fragmentFromString(camelCase(programName))}ErrorMessages[code];
}

/// Check if an error code belongs to the ${fragmentFromString(pascalCase(programName))} program.
bool ${fragmentFromString(isErrorFnName)}(int code) {
  return _${fragmentFromString(camelCase(programName))}ErrorMessages.containsKey(code);
}`;
}

function escapeString(str: string): string {
  return str.replace(/'/g, "\\'").replace(/\n/g, "\\n");
}
