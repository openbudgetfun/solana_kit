# Documentation updates

- When public APIs or behavior change, update the affected public docs in the same change.
- Run `docs:update` when examples, generated docs blocks, source comment consumers, or workspace metadata need to be refreshed.
- Run `docs:check` before finishing API or documentation work.
- Prefer updating the source inputs for generated docs instead of patching generated output alone.

## Upstream version tables

The `solana_kit` ↔ `@solana/kit` parity table in `readme.md` and the upstream client pin table in `docs/site/content/docs/reference/upstream-compatibility.md` are generated. Never hand-edit inside the `<!-- upstream-parity:start -->` / `<!-- upstream-pins:start -->` markers; `docs:check` fails when the rendered tables drift from their inputs.

- `config/upstream-versions.json` drives the parity table. Add a row for each published `solana_kit` release, keeping rows newest first and recording the `@solana/kit` version that release tracked (`null` for releases made before the workspace began tracking upstream).
- `config/reference-repos.json` drives the pin table, so refreshing a reference pin updates the published table in the same change.
- Run `dart run scripts/generate_upstream_docs.dart --write` to regenerate, or `docs:update` to regenerate everything. The script's `--check` mode runs as part of `docs:check`.
- Both tables are wrapped in a `dprint-ignore` comment so the generator owns their column alignment. Leave that comment in place.

## Docs site

The website in `docs/site` has a landing page at `/` and the documentation under `/docs/`. See `docs/site/README.md` for the layout.

- Every page under `docs/site/content/docs/` must be listed in `docs/site/lib/site/navigation.dart`; `docs/site/test/site_test.dart` fails otherwise. Moving a page means updating its route there and keeping its old URL as a `legacyRoute` so external links keep redirecting.
- Link between docs pages with base-relative paths such as `docs/core/codecs`, not page-relative ones: pages are served with a `<base href>`, so `../core/codecs` or `codecs` resolve against the site root.
- The landing page quotes the `// #docregion landing` regions of files in `examples/`. Keep those markers when editing the examples; the site build and tests fail if a region disappears.
