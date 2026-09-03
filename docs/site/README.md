# Solana Kit Docs Site

Jaspr Content documentation site for the Solana Kit workspace.

The site reuses shared Markdown template blocks via `mdt`, so run `docs:update` from the repository root whenever you change shared docs snippets. That command also refreshes synchronized `///` library doc comments that reuse the same provider blocks through `dart run scripts/sync_dart_doc_comments.dart`.

## Run Locally

From the repository root:

```bash
docs:update
docs:site:serve
```

The development server is available at `http://localhost:8080`.

## Build for Static Hosting

```bash
docs:site:build
```

To test the GitHub Pages base path behavior locally:

```bash
docs:site:build --dart-define=DOCS_BASE_PATH=/solana_kit/
```

Build output is written to `build/jaspr`.

## Smoke Test

```bash
docs:site:smoke
```

The smoke test builds the site and the embedded wallet demo for the base path in `DOCS_BASE_PATH` (default `/`), serves the build output locally, and verifies that every documented content page renders and that the wallet demo's base href and assets resolve under the deployment path. CI runs it with the GitHub Pages base path (`/solana_kit/` for this repository) so a demo built for the wrong base path fails before it can deploy.
