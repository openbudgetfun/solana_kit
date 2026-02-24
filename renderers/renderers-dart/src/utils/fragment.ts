import type { BaseFragment } from "@codama/renderers-core";

import { DartImportMap } from "./importMap.js";

/**
 * A Fragment represents a piece of generated Dart code
 * along with the imports it requires.
 */
export type Fragment = BaseFragment &
  Readonly<{
    imports: DartImportMap;
  }>;

/**
 * Create a Fragment from a tagged template literal.
 * Embedded Fragment values have their imports merged automatically.
 */
export function fragment(
  strings: TemplateStringsArray,
  ...values: (Fragment | string | number | boolean | undefined | null)[]
): Fragment {
  const imports = new DartImportMap();
  const parts: string[] = [];

  for (let i = 0; i < strings.length; i++) {
    parts.push(strings[i]);
    if (i < values.length) {
      const value = values[i];
      if (value != null && typeof value === "object" && "imports" in value) {
        parts.push(value.content);
        imports.mergeWith(value.imports);
      } else {
        parts.push(String(value ?? ""));
      }
    }
  }

  return {
    content: parts.join(""),
    imports,
  };
}

/**
 * Create an empty fragment.
 */
export function emptyFragment(): Fragment {
  return { content: "", imports: new DartImportMap() };
}

/**
 * Create a fragment from a raw string.
 */
export function fragmentFromString(content: string): Fragment {
  return { content, imports: new DartImportMap() };
}

/**
 * Merge multiple fragments with a joiner function.
 */
export function mergeFragments(
  fragments: Fragment[],
  joiner: (contents: string[]) => string,
): Fragment {
  const imports = new DartImportMap();
  const contents: string[] = [];

  for (const frag of fragments) {
    contents.push(frag.content);
    imports.mergeWith(frag.imports);
  }

  return { content: joiner(contents), imports };
}

/**
 * Helper to add a Dart import to a fragment and return a type name fragment.
 */
export function use(typeName: string, module: string): Fragment {
  const imports = new DartImportMap();
  imports.add(module);
  return { content: typeName, imports };
}
