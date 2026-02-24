import { existsSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { join, dirname, relative, posix } from "node:path";

import { type RootNode } from "@codama/nodes";
import { rootNodeVisitor, visit } from "@codama/visitors-core";
import { deleteDirectory, writeRenderMap } from "@codama/renderers-core";

import type { Fragment } from "../utils/fragment.js";
import type { RenderOptions } from "../utils/options.js";
import { DartImportMap, DART_EXTERNAL_PACKAGE_MAP } from "../utils/importMap.js";
import { formatDartDirectory } from "../utils/formatCode.js";
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
  } = options;

  return rootNodeVisitor((root: RootNode) => {
    // 1. Optionally delete the output directory
    if (deleteFolderBeforeRendering && existsSync(outputDir)) {
      deleteDirectory(outputDir);
    }

    // 2. Build the render map
    const renderMap = visit(
      root,
      getRenderMapVisitor({ nameApi, dependencyMap }),
    );

    // 3. Build a map of definedType module keys to their render map paths
    const typePathMap: Record<string, string> = {};
    for (const renderPath of renderMap.keys()) {
      const match = renderPath.match(/^(?:.*\/)?types\/([a-z_]+)\.dart$/);
      if (match) {
        typePathMap[`definedType:${match[1]}`] = renderPath;
      }
    }

    // 4. Resolve imports and write files
    for (const [filePath, frag] of renderMap.entries()) {
      const fullPath = join(outputDir, filePath);
      const dir = dirname(fullPath);

      // Ensure directory exists
      if (!existsSync(dir)) {
        mkdirSync(dir, { recursive: true });
      }

      // Compute per-file internal import map (relative paths to defined types)
      const fileDir = dirname(filePath);
      const internalMap: Record<string, string> = {};
      for (const [key, typePath] of Object.entries(typePathMap)) {
        // Don't import yourself
        if (typePath === filePath) continue;
        let rel = posix.relative(fileDir, typePath);
        if (!rel.startsWith(".")) {
          rel = `./${rel}`;
        }
        internalMap[key] = rel;
      }

      // Resolve fragment content with imports
      const content = resolveFragmentContent(frag, dependencyMap ?? {}, internalMap);
      writeFileSync(fullPath, content, "utf-8");
    }

    // 4. Optionally format
    if (formatCode) {
      formatDartDirectory(outputDir);
    }
  });
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
