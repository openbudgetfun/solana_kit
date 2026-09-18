import type {
  LinkableDictionary,
} from "@codama/visitors-core";

import type { DartNameApi } from "./nameTransformers.js";
import type { TypeManifestVisitor } from "../visitors/getTypeManifestVisitor.js";

/**
 * A hand-written codec that backs a defined-type link in the rendered IDL.
 *
 * Some IDL fields cannot be expressed with Codama type nodes and need a
 * hand-written codec instead — for example, the Token-2022 TLV extension
 * region, which stops at the first `Uninitialized` header rather than
 * consuming every trailing byte. Codama has no "stop at a discriminator" type
 * node, so the IDL is prepared to link the inner type to a name and the
 * renderer is told which hand-written codec backs that link. Wrappers around
 * the link (`Option`, `HiddenPrefix`, …) still come from the IDL, so the wire
 * format is unchanged.
 */
export interface LinkOverride {
  /** The Dart file the codec lives in, relative to the package's `lib/`. */
  path: string;
  /** The Dart type the link resolves to, e.g. `List<Extension>`. */
  type: string;
  /** The encoder expression, e.g. `getExtensionsEncoder()`. */
  encoder: string;
  /** The decoder expression, e.g. `getExtensionsDecoder()`. */
  decoder: string;
}

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
  /**
   * Hand-written codec overrides for defined-type links, keyed by the link
   * name as it appears in Codama nodes. A link with a matching key emits the
   * override's type and codec expressions instead of resolving to a generated
   * type file, and imports the override's Dart file.
   */
  linkOverrides?: Record<string, LinkOverride>;
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
