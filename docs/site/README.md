# Solana Kit Docs Site

The Solana Kit website: a landing page and the documentation, built with [Jaspr Content](https://docs.jaspr.site/content) and drawn by hand with [skribble](https://skribble.dev/)'s Jaspr components, lettered in Noto Sketch.

The site reuses shared Markdown template blocks via `mdt`, so run `docs:update` from the repository root whenever you change shared docs snippets. That command also refreshes synchronized `///` library doc comments that reuse the same provider blocks through `dart run scripts/sync_dart_doc_comments.dart`.

## Structure

| Path                       | What it is                                                                                                                                                       |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `content/index.md`         | The landing page's title and description. The page itself is rendered by `lib/layouts/landing_layout.dart` and `lib/landing/`.                                   |
| `content/docs/**`          | Documentation pages, served under `/docs/`.                                                                                                                      |
| `lib/site/navigation.dart` | The documentation's information architecture. The sidebar, previous/next pager, and redirects from the old pre-`/docs/` URLs all come from this list.            |
| `lib/layouts/`             | The docs layout, the landing layout, their shared `<head>`, and the legacy redirect pages.                                                                       |
| `lib/components/`          | Header, footer, search, theme toggle, and the hand-drawn Markdown elements (code blocks, callouts, blockquotes, tables).                                         |
| `web/site.css`             | The whole visual system: the skribble paper-and-ink palette for light and dark mode, layout, and prose styles.                                                   |
| `web/site.js`              | Progressive enhancements: theme toggle, copy buttons, example tabs, mobile sidebar, table-of-contents tracking, and scroll reveals. Every page works without it. |
| `web/fonts/`               | Skribble Noto Sketch (body and headings) and Skribble Mono Playful (code), with their OFL licences.                                                              |

## Adding a docs page

1. Add the Markdown file under `content/docs/<section>/`.
2. Add a `DocsPage` for it to `docsSections` in `lib/site/navigation.dart`, in reading order.
3. Run `docs:update` to refresh the search index.

`test/site_test.dart` fails when a page under `content/docs/` is missing from the navigation, or the navigation lists a page that does not exist.

Markdown pages can use `<Info>`, `<Note>`, `<Tip>`, `<Success>`, `<Warning>`, and `<Error>` callouts, and `<WalletDemo height="720"></WalletDemo>` to embed the live wallet UI demo.

## Landing page examples

The code on the landing page is not copied into the site. Each example tab quotes the `landing` region of a runnable file in `examples/`:

```dart
// #docregion landing
final rpc = createSolanaRpc(url: 'https://api.devnet.solana.com');
// #enddocregion landing
```

A region may appear several times in one file; the pieces are joined with a blank line. The tabs are listed in `lib/landing/landing_examples.dart`. Versions and the package count on the landing page come from `versions.json` and the package pubspecs, so they never need hand edits. The build fails if an example or region is missing.

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

## Tests

```bash
dart test docs/site/test
```

`test:all` runs these with the rest of the workspace.

## Smoke Test

```bash
docs:site:smoke
```

The smoke test builds the site and the embedded wallet demo for the base path in `DOCS_BASE_PATH` (default `/`), serves the build output locally, and verifies that every documented content page renders, that the landing page quotes real example code, that the old pre-`/docs/` URLs redirect to their new pages, and that the wallet demo's base href and assets resolve under the deployment path. CI runs it with the GitHub Pages base path (`/solana_kit/` for this repository) so a demo built for the wrong base path fails before it can deploy.
