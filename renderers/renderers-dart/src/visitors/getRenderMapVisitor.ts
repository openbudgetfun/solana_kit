import {
  type AccountNode,
  type DefinedTypeNode,
  type InstructionNode,
  type PdaNode,
  type ProgramNode,
  type RootNode,
} from "@codama/nodes";
import {
  type RenderMap,
  addToRenderMap,
  createRenderMap,
  mergeRenderMaps,
} from "@codama/renderers-core";
import {
  type Visitor,
  LinkableDictionary,
  NodeStack,
  extendVisitor,
  pipe,
  recordLinkablesOnFirstVisitVisitor,
  recordNodeStackVisitor,
  staticVisitor,
  visit,
} from "@codama/visitors-core";

import type { Fragment } from "../utils/fragment.js";
import type { GetRenderMapOptions, RenderScope } from "../utils/options.js";
import { createDartNameApi } from "../utils/nameTransformers.js";
import { snakeCase } from "../utils/nameTransformers.js";
import { getTypeManifestVisitor } from "./getTypeManifestVisitor.js";

import { getAccountPageFragment } from "../fragments/accountPage.js";
import { getErrorPageFragment } from "../fragments/errorPage.js";
import { getIndexPageFragment, getRootIndexPageFragment } from "../fragments/indexPage.js";
import { getInstructionPageFragment } from "../fragments/instructionPage.js";
import { getPdaPageFragment } from "../fragments/pdaPage.js";
import { getProgramPageFragment } from "../fragments/programPage.js";
import { getTypePageFragment } from "../fragments/typePage.js";

/**
 * Creates a visitor that maps Codama nodes to a RenderMap of Dart files.
 */
export function getRenderMapVisitor(
  options: GetRenderMapOptions = {},
): Visitor<RenderMap<Fragment>, "rootNode" | "programNode" | "accountNode" | "definedTypeNode" | "instructionNode" | "pdaNode"> {
  const nameApi = {
    ...createDartNameApi(),
    ...options.nameApi,
  };
  const dependencyMap = options.dependencyMap ?? {};

  const stack = new NodeStack();
  const linkables = new LinkableDictionary();

  const typeManifestVisitor = getTypeManifestVisitor({
    nameApi,
    linkables,
    stack,
  });

  const scope: RenderScope = {
    nameApi,
    typeManifestVisitor,
    linkables,
    dependencyMap,
    internalImportMap: {},
  };

  return pipe(
    staticVisitor(
      () => createRenderMap<Fragment>(),
      {
        keys: [
          "rootNode",
          "programNode",
          "accountNode",
          "definedTypeNode",
          "instructionNode",
          "pdaNode",
        ],
      },
    ),
    (v) =>
      extendVisitor(v, {
        visitRoot(node: RootNode, { self }) {
          const programMaps = [
            visit(node.program, self),
            ...node.additionalPrograms.map((p) => visit(p, self)),
          ];

          return mergeRenderMaps(programMaps);
        },

        visitProgram(node: ProgramNode, { self }) {
          const programName = node.name as string;
          const maps: RenderMap<Fragment>[] = [];

          // Track file names for barrel exports
          const accountFiles: string[] = [];
          const instructionFiles: string[] = [];
          const typeFiles: string[] = [];
          const pdaFiles: string[] = [];
          const errorFiles: string[] = [];
          const programFiles: string[] = [];

          // Visit accounts
          for (const account of node.accounts ?? []) {
            maps.push(visit(account, self));
            accountFiles.push(`${snakeCase(account.name as string)}.dart`);
          }

          // Visit instructions
          for (const instruction of node.instructions ?? []) {
            maps.push(visit(instruction, self));
            instructionFiles.push(
              `${snakeCase(instruction.name as string)}.dart`,
            );
          }

          // Visit defined types
          for (const definedType of node.definedTypes ?? []) {
            maps.push(visit(definedType, self));
            typeFiles.push(
              `${snakeCase(definedType.name as string)}.dart`,
            );
          }

          // Visit PDAs
          for (const pda of node.pdas ?? []) {
            maps.push(visit(pda, self));
            pdaFiles.push(`${snakeCase(pda.name as string)}.dart`);
          }

          // Program page
          const programFragment = getProgramPageFragment(node, scope);
          const programFileName = `${snakeCase(programName)}.dart`;
          programFiles.push(programFileName);
          let programMap = createRenderMap<Fragment>();
          programMap = addToRenderMap(programMap, `programs/${programFileName}`, programFragment);
          maps.push(programMap);

          // Error page
          const errors = node.errors ?? [];
          if (errors.length > 0) {
            const errorFragment = getErrorPageFragment(node, scope);
            const errorFileName = `${snakeCase(programName)}.dart`;
            errorFiles.push(errorFileName);
            let errorMap = createRenderMap<Fragment>();
            errorMap = addToRenderMap(errorMap, `errors/${errorFileName}`, errorFragment);
            maps.push(errorMap);
          }

          // Barrel exports
          const categories: string[] = [];

          if (accountFiles.length > 0) {
            categories.push("accounts");
            let indexMap = createRenderMap<Fragment>();
            indexMap = addToRenderMap(
              indexMap,
              "accounts/accounts.dart",
              getIndexPageFragment(accountFiles),
            );
            maps.push(indexMap);
          }

          if (instructionFiles.length > 0) {
            categories.push("instructions");
            let indexMap = createRenderMap<Fragment>();
            indexMap = addToRenderMap(
              indexMap,
              "instructions/instructions.dart",
              getIndexPageFragment(instructionFiles),
            );
            maps.push(indexMap);
          }

          if (typeFiles.length > 0) {
            categories.push("types");
            let indexMap = createRenderMap<Fragment>();
            indexMap = addToRenderMap(
              indexMap,
              "types/types.dart",
              getIndexPageFragment(typeFiles),
            );
            maps.push(indexMap);
          }

          if (pdaFiles.length > 0) {
            categories.push("pdas");
            let indexMap = createRenderMap<Fragment>();
            indexMap = addToRenderMap(
              indexMap,
              "pdas/pdas.dart",
              getIndexPageFragment(pdaFiles),
            );
            maps.push(indexMap);
          }

          if (errorFiles.length > 0) {
            categories.push("errors");
            let indexMap = createRenderMap<Fragment>();
            indexMap = addToRenderMap(
              indexMap,
              "errors/errors.dart",
              getIndexPageFragment(errorFiles),
            );
            maps.push(indexMap);
          }

          if (programFiles.length > 0) {
            categories.push("programs");
            let indexMap = createRenderMap<Fragment>();
            indexMap = addToRenderMap(
              indexMap,
              "programs/programs.dart",
              getIndexPageFragment(programFiles),
            );
            maps.push(indexMap);
          }

          // Root barrel
          if (categories.length > 0) {
            let rootMap = createRenderMap<Fragment>();
            rootMap = addToRenderMap(
              rootMap,
              `${snakeCase(programName)}.dart`,
              getRootIndexPageFragment(categories),
            );
            maps.push(rootMap);
          }

          return mergeRenderMaps(maps);
        },

        visitAccount(node: AccountNode, { self }) {
          const fileName = `${snakeCase(node.name as string)}.dart`;
          const frag = getAccountPageFragment(node, scope);
          let map = createRenderMap<Fragment>();
          map = addToRenderMap(map, `accounts/${fileName}`, frag);
          return map;
        },

        visitDefinedType(node: DefinedTypeNode, { self }) {
          const fileName = `${snakeCase(node.name as string)}.dart`;
          const frag = getTypePageFragment(node, scope);
          let map = createRenderMap<Fragment>();
          map = addToRenderMap(map, `types/${fileName}`, frag);
          return map;
        },

        visitInstruction(node: InstructionNode, { self }) {
          const fileName = `${snakeCase(node.name as string)}.dart`;
          const frag = getInstructionPageFragment(node, scope);
          let map = createRenderMap<Fragment>();
          map = addToRenderMap(map, `instructions/${fileName}`, frag);
          return map;
        },

        visitPda(node: PdaNode, { self }) {
          const fileName = `${snakeCase(node.name as string)}.dart`;
          const frag = getPdaPageFragment(node, scope);
          let map = createRenderMap<Fragment>();
          map = addToRenderMap(map, `pdas/${fileName}`, frag);
          return map;
        },
      }),
    (v) => recordNodeStackVisitor(v, stack),
    (v) => recordLinkablesOnFirstVisitVisitor(v, linkables),
  );
}
