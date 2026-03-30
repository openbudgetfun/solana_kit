# Git and PR workflow

## Commit and PR titles

Commit and PR titles should follow:

```text
EMOJI TYPE(SCOPE): description
```

## Types

| Emoji | Type       | Use                                 |
| ----- | ---------- | ----------------------------------- |
| ✨    | `feat`     | New feature                         |
| 🐛    | `fix`      | Bug fix                             |
| 🔧    | `build`    | Build system, dependencies, tooling |
| 💚    | `ci`       | CI/CD changes                       |
| 🤖    | `chore`    | Maintenance, miscellaneous          |
| 📝    | `docs`     | Documentation                       |
| ♻️     | `refactor` | Code refactoring                    |
| 🧪    | `test`     | Tests                               |
| ⚡    | `perf`     | Performance                         |
| 🎨    | `style`    | Code style, formatting              |
| 🎉    | `init`     | Initial or first-time setup         |
| 🌱    | `seed`     | Scaffold or stub packages           |

## Branch hygiene

- Rebase onto `main` regularly while working to minimize merge conflicts.
- Always check the PR for merge conflicts before merging.
- If the branch is behind or the PR shows conflicts, rebase onto the latest `main` and resolve them before merging.
- Use rebase instead of merge commits to absorb upstream changes.

## PR checks

- When creating or updating a PR, use the scheduler to follow up on failing checks until they are resolved or escalated.
- Do not leave failing required checks unaddressed.
- If a rebase or force-push invalidates checks, schedule another follow-up.

## Merge strategy

- Only use squash merging.

## Examples

- `✨ feat(solana_kit_errors): error codes and messages`
- `🔧 build: devenv and FVM configuration`
- `💚 ci: GitHub Actions workflows`
