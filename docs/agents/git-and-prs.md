# Git and PR conventions

Every commit and PR title should follow:

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

## Examples

- `✨ feat(solana_kit_errors): error codes and messages`
- `🔧 build: devenv and FVM configuration`
- `💚 ci: GitHub Actions workflows`
