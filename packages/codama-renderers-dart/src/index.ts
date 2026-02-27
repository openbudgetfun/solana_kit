export { renderVisitor } from "./visitors/renderVisitor.js";
export { getRenderMapVisitor } from "./visitors/getRenderMapVisitor.js";
export { getTypeManifestVisitor } from "./visitors/getTypeManifestVisitor.js";
export { DartImportMap, DART_EXTERNAL_PACKAGE_MAP } from "./utils/importMap.js";
export { createDartNameApi } from "./utils/nameTransformers.js";
export type { DartNameApi } from "./utils/nameTransformers.js";
export type { RenderOptions, GetRenderMapOptions, RenderScope } from "./utils/options.js";
export type { TypeManifest } from "./utils/typeManifest.js";
export type { Fragment } from "./utils/fragment.js";

// Default export for Codama CLI integration
import { renderVisitor } from "./visitors/renderVisitor.js";
export default renderVisitor;
