import { existsSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { join, dirname, relative, posix } from "node:path";

import { type RootNode } from "@codama/nodes";
import { rootNodeVisitor, visit } from "@codama/visitors-core";
import { deleteDirectory, writeRenderMap } from "@codama/renderers-core";

import type { Fragment } from "../utils/fragment.js";
import type { RenderOptions, LinkOverride } from "../utils/options.js";
import { DartImportMap, DART_EXTERNAL_PACKAGE_MAP } from "../utils/importMap.js";
import { formatDartDirectory } from "../utils/formatCode.js";
import { normalizeRootNode } from "../utils/normalizeRootNode.js";
import { getRenderMapVisitor } from "./getRenderMapVisitor.js";

/**
 * Creates a visitor that renders Codama nodes as Dart files.
 *
 * @param outputDir - The directory to write generated files into (e.g., 'lib/src/generated')
 * @param options - Rendering options
 */
export function renderVisitor(
  outputDir: string,
  options: RenderOptions = {},
) {
  const {
    deleteFolderBeforeRendering = true,
    formatCode = false,
    nameApi,
    dependencyMap,
    linkOverrides,
  } = options;

  return rootNodeVisitor((root: RootNode) => {
    const normalizedRoot = normalizeRootNode(root);

    // 2. Build the render map
    const renderMap = visit(
      normalizedRoot,
      getRenderMapVisitor({ nameApi, dependencyMap, linkOverrides }),
    );

    // 3. Build a map of definedType module keys to their render map paths
    const typePathMap: Record<string, string> = {};
    for (const renderPath of renderMap.keys()) {
      const match = renderPath.match(/^(?:.*\/)?types\/([a-z0-9_]+)\.dart$/);
      if (match) {
        typePathMap[`definedType:${match[1]}`] = renderPath;
      }
    }

    // Resolve every file before deleting previous output, so invalid IDLs fail safely.
    const files: [string, string][] = [];
    for (const [filePath, frag] of renderMap.entries()) {
      const fullPath = join(outputDir, filePath);
      // Compute per-file internal import map (relative paths to defined types)
      const fileDir = dirname(filePath);
      const internalMap: Record<string, string> = {};
      for (const [key, typePath] of Object.entries(typePathMap)) {
        // Keep the key resolved without generating a self-import.
        if (typePath === filePath) {
          internalMap[key] = "";
          continue;
        }

        let rel = posix.relative(fileDir, typePath);
        if (!rel.startsWith(".")) {
          rel = `./${rel}`;
        }
        internalMap[key] = rel;
      }

      // Resolve fragment content with imports
      const content = resolveFragmentContent(
        frag,
        {
          ...(dependencyMap ?? {}),
          ...linkOverrideImports(outputDir, filePath, options.linkOverrides ?? {}),
        },
        internalMap,
      );
      files.push([fullPath, content]);
    }

    if (deleteFolderBeforeRendering && existsSync(outputDir)) {
      deleteDirectory(outputDir);
    }

    for (const [fullPath, content] of files) {
      mkdirSync(dirname(fullPath), { recursive: true });
      writeFileSync(fullPath, content, "utf-8");
    }

    // 4. Optionally format
    if (formatCode) {
      formatDartDirectory(outputDir);
    }
  });
}

/**
 * Resolve `linkOverride:` logical import keys into relative Dart imports.
 *
 * Override paths are relative to the package's `lib/` directory, while
 * generated files live under `lib/src/generated/...`, so each consuming file
 * needs its own relative path. Both sides are resolved against the package's
 * `lib/` root, which is located by walking up from the output directory.
 */
function linkOverrideImports(
  outputDir: string,
  generatedFilePath: string,
  overrides: Record<string, LinkOverride>,
): Record<string, string> {
  const resolved: Record<string, string> = {};

  if (Object.keys(overrides).length === 0) return resolved;

  // Override paths are resolved against the package's `lib/` directory, so
  // without one there is nothing to anchor them to. Failing loudly beats
  // emitting an import that cannot resolve.
  const libRoot = findLibRoot(outputDir);

  if (libRoot == null) {
    throw new Error(
      `Cannot resolve linkOverrides because the render output directory ` +
        `"${outputDir}" has no "lib" ancestor.`,
    );
  }

  const generatedAbsolute = posix.join(
    posix.resolve(outputDir),
    generatedFilePath,
  );

  for (const override of Object.values(overrides)) {
    const overrideAbsolute = posix.join(libRoot, override.path);
    let rel = posix.relative(posix.dirname(generatedAbsolute), overrideAbsolute);

    if (!rel.startsWith(".")) {
      rel = `./${rel}`;
    }
    resolved[`linkOverride:${override.path}`] = rel;
  }

  return resolved;
}

/**
 * Find the package `lib/` directory containing the render output, so relative
 * imports can point outside the generated tree. Returns null when the output
 * directory has no `lib` ancestor, in which case overrides cannot be linked.
 */
function findLibRoot(outputDir: string): string | null {
  const segments = posix.resolve(outputDir).split("/");
  const libIndex = segments.lastIndexOf("lib");

  if (libIndex < 0) return null;
  return segments.slice(0, libIndex + 1).join("/");
}

/**
 * Resolve a fragment into its final Dart file content,
 * prepending the resolved import statements.
 */
function resolveFragmentContent(
  frag: Fragment,
  dependencyMap: Record<string, string>,
  internalMap: Record<string, string> = {},
): string {
  const { content, imports } = frag;

  const importStr = imports.toString({
    ...internalMap,
    ...dependencyMap,
  });

  if (!importStr) {
    return content + "\n";
  }

  // Split content into header comment and rest
  const lines = content.split("\n");
  const headerLines: string[] = [];
  let restIndex = 0;

  for (let i = 0; i < lines.length; i++) {
    if (
      lines[i].startsWith("//") ||
      lines[i].trim() === ""
    ) {
      headerLines.push(lines[i]);
      restIndex = i + 1;
    } else {
      break;
    }
  }

  const header = headerLines.join("\n");
  const rest = lines.slice(restIndex).join("\n");

  // Clean up: remove the use() placeholder text from content
  const cleanContent = cleanFragmentContent(rest);

  return `${header}\n\n${importStr}\n\n${cleanContent}\n`;
}

/**
 * Remove use() placeholder fragments from content.
 * The use() function produces just the type name in content,
 * but when used standalone (not in a template), it leaves
 * lines like just "Uint8List" that need to be removed.
 */
function cleanFragmentContent(content: string): string {
  // Remove lines that are just standalone identifier names from use() calls.
  // These are artifacts of the import tracking pattern where use() is called
  // purely for its import side-effect. Matches: PascalCase, camelCase,
  // and multi-word identifiers like "getStructEncoder".
  const lines = content.split("\n");
  const cleanLines = lines.filter((line) => {
    const trimmed = line.trim();
    // Skip lines that are a single identifier (no spaces, no punctuation)
    if (/^[a-zA-Z][a-zA-Z0-9]*$/.test(trimmed)) {
      return false;
    }
    return true;
  });
  return cleanLines.join("\n");
}
