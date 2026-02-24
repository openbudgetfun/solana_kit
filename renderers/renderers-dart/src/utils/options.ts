import type {
  LinkableDictionary,
} from "@codama/visitors-core";

import type { DartNameApi } from "./nameTransformers.js";
import type { TypeManifestVisitor } from "../visitors/getTypeManifestVisitor.js";

/**
 * Options for the top-level renderVisitor.
 */
export interface RenderOptions extends GetRenderMapOptions {
  /** Whether to delete the output folder before rendering. Default: true. */
  deleteFolderBeforeRendering?: boolean;
  /** Whether to run `dart format` on generated files. Default: false. */
  formatCode?: boolean;
  /** The Dart package name for pubspec.yaml generation. */
  dartPackageName?: string;
  /** Custom dependency overrides for the generated pubspec.yaml. */
  dartDependencies?: Record<string, string>;
}

/**
 * Options for the getRenderMapVisitor.
 */
export interface GetRenderMapOptions {
  /** Custom name API overrides. */
  nameApi?: Partial<DartNameApi>;
  /** Dependency map overrides (logical module -> Dart package URI). */
  dependencyMap?: Record<string, string>;
}

/**
 * Shared rendering context passed to fragment generators.
 */
export interface RenderScope {
  /** The resolved name API for Dart naming conventions. */
  nameApi: DartNameApi;
  /** The type manifest visitor for resolving type nodes. */
  typeManifestVisitor: TypeManifestVisitor;
  /** Linkable nodes dictionary for cross-references. */
  linkables: LinkableDictionary;
  /** Custom dependency map. */
  dependencyMap: Record<string, string>;
  /** Internal import map (logical name -> relative file path). */
  internalImportMap: Record<string, string>;
}
