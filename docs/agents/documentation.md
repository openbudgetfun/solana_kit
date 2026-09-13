# Documentation updates

- When public APIs or behavior change, update the affected public docs in the same change.
- Run `docs:update` when examples, generated docs blocks, source comment consumers, or workspace metadata need to be refreshed.
- Run `docs:check` before finishing API or documentation work.
- Prefer updating the source inputs for generated docs instead of patching generated output alone.

## Upstream version tables

The `solana_kit` ↔ `@solana/kit` parity table in `readme.md` and the upstream client pin table in `docs/site/content/reference/upstream-compatibility.md` are generated. Never hand-edit inside the `<!-- upstream-parity:start -->` / `<!-- upstream-pins:start -->` markers; `docs:check` fails when the rendered tables drift from their inputs.

- `config/upstream-versions.json` drives the parity table. Add a row for each published `solana_kit` release, keeping rows newest first and recording the `@solana/kit` version that release tracked (`null` for releases made before the workspace began tracking upstream).
- `config/reference-repos.json` drives the pin table, so refreshing a reference pin updates the published table in the same change.
- Run `dart run scripts/generate_upstream_docs.dart --write` to regenerate, or `docs:update` to regenerate everything. The script's `--check` mode runs as part of `docs:check`.
- Both tables are wrapped in a `dprint-ignore` comment so the generator owns their column alignment. Leave that comment in place.
