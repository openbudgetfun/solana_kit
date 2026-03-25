# Release and changesets

## Changesets

- Never delete files in `.changeset/`; they are release inputs.
- Any PR that changes files under `packages/*` must include a `.changeset/*.md` file.
- This workspace ships shared versions across published packages, so changesets must not use package-specific keys.
- Every changeset frontmatter block must contain exactly one entry:

```markdown
---
default: patch
---
```

Valid bump values are:

- `patch`
- `minor`
- `major`

If `knope document-change` generates package-specific keys, replace them with a single `default: patch|minor|major` entry before committing.

## Release workflow

Use [knope](https://knope.tech/) for release management:

```bash
knope document-change
knope --dry-run release
knope release
```

## Publishing notes

- Release metadata and package inventory live in [`docs/publishing-guide.md`](../publishing-guide.md).
- Use dry runs before real release or publish actions.
- Keep the worktree clean before release-oriented commands.
