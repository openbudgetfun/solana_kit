# Solana Kit Docs Site

Jaspr Content documentation site for the Solana Kit workspace.

The site reuses shared Markdown template blocks via `mdt`, so run `docs:update` from the repository root whenever you change shared docs snippets.

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
