# Changelog

## 0.1.1 (2026-02-27)

### Features

- Add `codama-renderers-solana-kit-dart` - a Codama renderer that generates Dart code targeting the solana_kit SDK from Codama IDL definitions.

### Fixes

- Document chore: add nixpkgs tooling and stabilize coverage command.
- Document ci: add publish and release workflow automation.
- Document ci: enforce changesets for package modifications.
- Fix code generation bugs: AccountRole enum names, cross-type imports, transformDecoder callback signature, template literal interpolation, missing codec imports, and nullable field assertions. Add comprehensive e2e test suite with snapshot tests, JS comparison tests, and Dart validation.

## 0.1.0

### Features

- Initial release of `codama-renderers-solana-kit-dart`
- Generate Dart code from Codama IDL targeting the solana_kit SDK
- Support for accounts, instructions, defined types, errors, PDAs, and programs
- Type manifest visitor mapping all Codama type nodes to Dart types and codecs
- Fragment-based code generation with automatic import tracking
- Comprehensive test suite with 261 tests
