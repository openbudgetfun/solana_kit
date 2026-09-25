import type { Fragment } from "../utils/fragment.js";
import { fragmentFromString } from "../utils/fragment.js";

/**
 * Generate a barrel export Dart file that exports all files in a category.
 */
export function getIndexPageFragment(
  fileNames: string[],
  relativePath: string = "",
): Fragment {
  if (fileNames.length === 0) {
    return fragmentFromString(
      "// Auto-generated. Do not edit.\n// ignore_for_file: type=lint\n",
    );
  }

  const exports = fileNames
    .sort()
    .map((f) => {
      const path = relativePath ? `${relativePath}/${f}` : f;
      return `export '${path}';`;
    })
    .join("\n");

  return fragmentFromString(
    `// Auto-generated. Do not edit.\n// ignore_for_file: type=lint\n\n${exports}\n`,
  );
}

/**
 * Generate the root barrel export file.
 */
export function getRootIndexPageFragment(
  categories: string[],
): Fragment {
  const exports = categories
    .sort()
    .map((cat) => `export '${cat}/${cat}.dart';`)
    .join("\n");

  return fragmentFromString(
    `// Auto-generated. Do not edit.\n// ignore_for_file: type=lint\n\n${exports}\n`,
  );
}
