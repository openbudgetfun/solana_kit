# Changesets and releases

## Changesets

- Never delete files in `.changeset/`; they are release inputs.
- Any PR that changes files under `packages/*` must include a `.changeset/*.md` file.
- This workspace ships shared versions across published packages, so changesets must not use package-specific keys.
- Every changeset frontmatter block must contain exactly one entry:

```md
---
default: patch
---
```

Valid values are `patch`, `minor`, or `major`.

If `knope document-change` generates package-specific keys, replace them with a single `default: patch|minor|major` entry before committing.

## Release workflow

Use dry runs before real release actions.

```bash
knope document-change
knope --dry-run release
```

For the full release flow, see the publishing docs.
