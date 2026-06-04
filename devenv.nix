{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  currentDir = builtins.dirOf __curPos.file;
  extra = inputs.ifiokjr-nixpkgs.packages.${pkgs.stdenv.system};
in
{
  packages =
    with pkgs;
    [
      dprint
      fvm
      gitleaks
      jq
      ktlint
      libiconv
      nixfmt
      osv-scanner
      ripgrep
      shfmt
      taplo
      zizmor
      extra.mdt
      extra.monochange
      extra.pnpm
      extra.surfpool
    ]
    ++ lib.optionals stdenv.isDarwin [
      coreutils
    ];

  enterShell = ''
    set -euo pipefail
    eval "$(pnpm-activate-env)"
    dartfmt:hash
  '';

  dotenv.disableHint = true;

  # Rely on the global sdk for now as the nix apple sdk is not working for me.
  apple.sdk = null;

  git-hooks = {
    package = pkgs.prek;
    hooks = {
      "secrets:commit" = {
        enable = true;
        name = "secrets:commit";
        description = "Scan staged changes for leaked secrets with gitleaks.";
        entry = "${pkgs.gitleaks}/bin/gitleaks protect --staged --verbose --redact --config .gitleaks.toml";
        pass_filenames = false;
        stages = [ "pre-commit" ];
      };
      "secrets:push" = {
        enable = true;
        name = "secrets:push";
        description = "Check entire git history for leaked secrets with gitleaks.";
        entry = "${pkgs.gitleaks}/bin/gitleaks detect --verbose --redact --config .gitleaks.toml";
        pass_filenames = false;
        stages = [ "pre-push" ];
      };
      "lint:commit" = {
        enable = true;
        name = "lint:commit";
        description = "Run formatting checks on every commit.";
        entry = "${config.env.DEVENV_PROFILE}/bin/lint:format";
        pass_filenames = true;
        always_run = true;
        stages = [ "pre-commit" ];
      };
      "lint:push" = {
        enable = true;
        name = "lint:push";
        description = "Run linting checks on every push.";
        entry = "${config.env.DEVENV_PROFILE}/bin/lint:push";
        pass_filenames = true;
        always_run = true;
        stages = [ "pre-push" ];
      };
    };
  };

  scripts = {
    "flutter" = {
      exec = ''
        # Unset Nix toolchain variables that conflict with Xcode builds
        unset CC CXX LD AR NM RANLIB STRIP OBJCOPY OBJDUMP SIZE STRINGS
        unset NIX_CC NIX_BINTOOLS NIX_CFLAGS_COMPILE NIX_LDFLAGS
        unset NIX_HARDENING_ENABLE NIX_ENFORCE_NO_NATIVE
        unset NIX_DONT_SET_RPATH NIX_DONT_SET_RPATH_FOR_BUILD NIX_NO_SELF_RPATH
        unset NIX_IGNORE_LD_THROUGH_GCC
        unset NIX_BINTOOLS_WRAPPER_TARGET_HOST_arm64_apple_darwin
        unset NIX_CC_WRAPPER_TARGET_HOST_arm64_apple_darwin
        unset NIX_PKG_CONFIG_WRAPPER_TARGET_HOST_arm64_apple_darwin
        unset SDKROOT MACOSX_DEPLOYMENT_TARGET
        unset CFLAGS CXXFLAGS LDFLAGS ARCHFLAGS
        unset PKG_CONFIG PKG_CONFIG_PATH
        unset LD_LIBRARY_PATH LD_DYLD_PATH
        unset cmakeFlags
        set -euo pipefail
        fvm flutter $@
      '';
      description = "Run flutter commands.";
    };
    "dart" = {
      exec = ''
        set -euo pipefail
        fvm dart $@
      '';
      description = "Run dart commands.";
    };
    "jaspr" = {
      exec = ''
        set -euo pipefail
        dart run jaspr_cli:jaspr $@
      '';
      description = "Run the jaspr cli.";
    };
    "melos" = {
      exec = ''
        set -euo pipefail
        dart run melos $@
      '';
      description = "Run the melos cli.";
    };
    "format_coverage" = {
      exec = ''
        set -euo pipefail
        dart run coverage:format_coverage $@
      '';
      description = "Run the format_coverage command from the coverage package.";
    };
    "dartfmt" = {
      exec = ''
        set -euo pipefail
        file="$1"
        shift || true
        dir="$(dirname "$file")"
        base="$(basename "$file")"
        (
          cd "$dir"
          dart format -o show "$base" "$@" | sed '$d'
        )
      '';
      description = "The dart format executable for formatting the workspace.";
      binary = "bash";
    };
    "dartfmt:hash" = {
      exec = ''
        set -euo pipefail
        cd "''${DEVENV_ROOT:-${currentDir}}"

        find . \( -name pubspec.yaml -o -name analysis_options.yaml -o -name pubspec.lock \) \
          | sort \
          | ${pkgs.findutils}/bin/xargs ${pkgs.coreutils}/bin/sha256sum \
          | ${pkgs.coreutils}/bin/sha256sum \
          | cut -d' ' -f1 > .dartfmt.txt
      '';
      description = "Write .dartfmt.txt from pubspec, analysis options, and lockfile contents.";
      binary = "bash";
    };
    "install:all" = {
      exec = ''
        set -euo pipefail
        install:dart
      '';
      description = "Run all install scripts.";
      binary = "bash";
    };
    "install:dart" = {
      exec = ''
        set -euo pipefail
        flutter pub get
      '';
      description = "Install dart dependencies";
      binary = "bash";
    };
    "fix:all" = {
      exec = ''
        set -euo pipefail
        docs:update
        fix:lint
        fix:workflows
        mc check --fix
        fix:format
      '';
      description = "Fix all fixable issues.";
      binary = "bash";
    };
    "fix:format" = {
      exec = ''
        set -euo pipefail
        dprint fmt --config "$DEVENV_ROOT/dprint.json" -L debug
      '';
      description = "Fix formatting for entire project.";
      binary = "bash";
    };
    "fix:lint" = {
      exec = ''
        set -euo pipefail
        dart fix --apply
        ktlint -F
      '';
      description = "Fix lint issues across all packages.";
      binary = "bash";
    };
    "lint:all" = {
      exec = ''
        set -euo pipefail
        docs:check
        lint:format
        lint:kotlin
        lint:analyze
        lint:workflows
        mc check
      '';
      description = "Run all lint checks.";
      binary = "bash";
    };
    "lint:push" = {
      exec = ''
        set -euo pipefail

        ${currentDir}/.devenv/profile/bin/docs:check
        ${currentDir}/.devenv/profile/bin/lint:format
        ${currentDir}/.devenv/profile/bin/lint:kotlin
        ${currentDir}/.devenv/profile/bin/lint:analyze
        ${currentDir}/.devenv/profile/bin/lint:workflows
        ${extra.monochange}/bin/mc check
      '';
      description = "Run all lint checks before `git push`.";
      binary = "bash";
    };
    "lint:format" = {
      exec = ''
        set -euo pipefail
        ${pkgs.dprint}/bin/dprint check
      '';
      description = "Check all formatting is correct.";
    };
    "lint:analyze" = {
      exec = ''
        set -euo pipefail
        dart analyze --fatal-infos .
      '';
      description = "Run dart analyze across all packages.";
      binary = "bash";
    };
    "lint:kotlin" = {
      exec = ''
        ktlint
      '';
      description = "Lint tracked Kotlin files with ktlint.";
      binary = "bash";
    };
    "lint:workflows" = {
      exec = ''
        set -euo pipefail
        zizmor .github/workflows/ .github/actions/
      '';
      description = "Scan GitHub Actions workflows and actions for security vulnerabilities with zizmor.";
      binary = "bash";
    };
    "fix:workflows" = {
      exec = ''
        set -euo pipefail
        zizmor --fix .github/workflows/ .github/actions/
      '';
      description = "Auto-fix zizmor findings in GitHub Actions workflows where possible.";
      binary = "bash";
    };
    "mdt:info" = {
      exec = ''
        set -euo pipefail
        mkdir -p .mdt/cache
        mdt info
      '';
      description = "Inspect discovered mdt providers/consumers and cache reuse telemetry.";
      binary = "bash";
    };
    "mdt:doctor" = {
      exec = ''
        set -euo pipefail
        mkdir -p .mdt/cache
        mdt doctor --format text
      '';
      description = "Run mdt health checks with actionable remediation hints.";
      binary = "bash";
    };
    "docs:check" = {
      exec = ''
        set -euo pipefail
        mkdir -p .mdt/cache
        mdt check --verbose
        dart run "$DEVENV_ROOT/scripts/sync_dart_doc_comments.dart" --check
        # Prime the cache history so mdt doctor can evaluate cache efficiency
        # in fresh CI checkouts without returning a cache-history-only skip.
        mdt info >/dev/null
        mdt info >/dev/null
        mdt doctor --format text
        dart run scripts/workspace_doc_drift.dart --check
      '';
      description = "Check documentation consistency with mdt, synchronized Dart doc comments, and workspace metadata.";
      binary = "bash";
    };
    "docs:update" = {
      exec = ''
        set -euo pipefail
        mkdir -p .mdt/cache
        mdt update --verbose
        dart run "$DEVENV_ROOT/scripts/sync_dart_doc_comments.dart" --write
        dart run scripts/workspace_doc_drift.dart --write
        mdt info
      '';
      description = "Update generated documentation blocks across Markdown and Dart doc comments, then print mdt diagnostics.";
      binary = "bash";
    };
    "docs:site:serve" = {
      exec = ''
        set -euo pipefail
        cd "$DEVENV_ROOT/docs/site"
        flutter pub get
        fvm dart run jaspr_cli:jaspr serve "$@"
      '';
      description = "Serve the Jaspr documentation site locally.";
      binary = "bash";
    };
    "docs:site:build" = {
      exec = ''
        set -euo pipefail
        cd "$DEVENV_ROOT/docs/site"
        flutter pub get
        fvm dart run build_runner clean
        PORT="''${DOCS_BUILD_PORT:-9080}" fvm dart run jaspr_cli:jaspr build "$@"
      '';
      description = "Build the Jaspr documentation site for static hosting.";
      binary = "bash";
    };
    "docs:site:smoke" = {
      exec = ''
        set -euo pipefail
        dart run "$DEVENV_ROOT/scripts/docs_site_smoke.dart" "$@"
      '';
      description = "Run smoke tests against the built documentation site.";
      binary = "bash";
    };
    "upstream:check" = {
      exec = ''
        set -euo pipefail
        dart run "$DEVENV_ROOT/scripts/check_upstream_compatibility.dart" "$@"
      '';
      description = "Check tracked upstream compatibility metadata and local drift.";
      binary = "bash";
    };
    "upstream:parity" = {
      exec = ''
        set -euo pipefail
        dart run "$DEVENV_ROOT/scripts/check_upstream_parity.dart" "$@"
      '';
      description = "Generate runtime fixtures from the tracked @solana/kit release and compare selected behaviors against this Dart port.";
      binary = "bash";
    };
    "audit:deps" = {
      exec = ''
        set -euo pipefail

        mapfile -t lockfiles < <(
          find "$DEVENV_ROOT" -type f \( -name 'pubspec.lock' -o -name 'pnpm-lock.yaml' \) \
            | rg -v '/(\.git|\.dart_tool|\.repos|coverage|build|dist)/' \
            | sort
        )

        if [ ''${#lockfiles[@]} -eq 0 ]; then
          echo "No lockfiles were found to audit."
          exit 1
        fi

        args=()
        for lockfile in "''${lockfiles[@]}"; do
          args+=("-L" "$lockfile")
        done

        echo "Auditing ''${#lockfiles[@]} lockfile(s) with osv-scanner..."
        osv-scanner scan source "''${args[@]}" --allow-no-lockfiles
      '';
      description = "Audit current Dart and pnpm lockfiles for known vulnerabilities with osv-scanner.";
      binary = "bash";
    };
    "bench:all" = {
      exec = ''
        set -euo pipefail
        benchmark_manifest="$(mktemp)"
        trap 'rm -f "$benchmark_manifest"' EXIT

        find "$DEVENV_ROOT/packages" -mindepth 3 -maxdepth 3 -type f -path '*/benchmark/*.dart' | sort > "$benchmark_manifest"

        if [ ! -s "$benchmark_manifest" ]; then
          echo "No benchmark scripts were found under packages/*/benchmark/."
          exit 1
        fi

        while IFS= read -r benchmark; do
          pkg_dir="$(dirname "$(dirname "$benchmark")")"
          rel_benchmark="''${benchmark#"$pkg_dir"/}"

          echo "Running benchmark: $benchmark"
          (
            cd "$pkg_dir"
            dart run "$rel_benchmark"
          )
        done < "$benchmark_manifest"
      '';
      description = "Run all local benchmark scripts across workspace packages.";
      binary = "bash";
    };
    "test:integration" = {
      exec = ''
        set -euo pipefail
        dart "$DEVENV_ROOT/scripts/run_integration_tests.dart" "$@"
      '';
      description = "Run all integration tests against SurfPool local validator.";
      binary = "bash";
    };
    "test:all" = {
      exec = ''
        set -euo pipefail
        dart "$DEVENV_ROOT/scripts/run_workspace_tests.dart" "$@"
      '';
      description = "Run all tests across workspace packages and root doc-comment checks.";
      binary = "bash";
    };
    "test:doc-snippets" = {
      exec = ''
        set -euo pipefail
        dart test test/doc_comment_snippets_test.dart
      '';
      description = "Analyze synchronized Dart doc-comment snippets for compile-time drift.";
      binary = "bash";
    };
    "test:coverage" = {
      exec = ''
        set -euo pipefail
        dart "$DEVENV_ROOT/scripts/run_workspace_coverage.dart" "$@"
      '';
      description = "Generate merged LCOV coverage for all packages.";
      binary = "bash";
    };
    "coverage:check" = {
      exec = ''
        set -euo pipefail
        dart run "$DEVENV_ROOT/scripts/check_risk_tier_coverage.dart"
      '';
      description = "Run package-level coverage for risk-tier packages and enforce configured line-coverage floors.";
      binary = "bash";
    };
    "clone:repos" = {
      exec = ''
        set -euo pipefail
        config_file="$DEVENV_ROOT/config/reference-repos.json"
        jq_bin="${pkgs.jq}/bin/jq"

        mkdir -p "$DEVENV_ROOT/.repos"

        sync_reference_repo() {
          local name="$1" path="$2" url="$3" ref_type="$4" ref_value="$5"
          local dest="$DEVENV_ROOT/$path"

          mkdir -p "$(dirname "$dest")"

          case "$ref_type" in
            branch)
              if [ -d "$dest/.git" ]; then
                echo "Updating $path on branch $ref_value..."
                git -C "$dest" fetch origin --quiet
                git -C "$dest" checkout --quiet "$ref_value"
                git -C "$dest" pull --ff-only origin "$ref_value"
              else
                echo "Cloning $name on branch $ref_value..."
                git clone --branch "$ref_value" "$url" "$dest"
              fi
              ;;
            tag)
              if [ -d "$dest/.git" ]; then
                echo "Checking $path at tag $ref_value..."
                git -C "$dest" fetch origin --tags --quiet
                git -C "$dest" checkout --quiet "$ref_value"
              else
                echo "Cloning $name at tag $ref_value..."
                git clone --branch "$ref_value" --depth 1 "$url" "$dest"
              fi
              ;;
            commit)
              if [ -d "$dest/.git" ]; then
                echo "Checking $path at commit $ref_value..."
                git -C "$dest" fetch origin --quiet
              else
                echo "Cloning $name at commit $ref_value..."
                git clone "$url" "$dest"
              fi
              git -C "$dest" checkout --quiet "$ref_value"
              ;;
            *)
              echo "Unknown ref type '$ref_type' for $name" >&2
              return 1
              ;;
          esac
        }

        while IFS= read -r repo_json; do
          name="$($jq_bin -r '.name' <<<"$repo_json")"
          path="$($jq_bin -r '.path' <<<"$repo_json")"
          url="$($jq_bin -r '.url' <<<"$repo_json")"
          ref_type="$($jq_bin -r '.ref.type' <<<"$repo_json")"
          ref_value="$($jq_bin -r '.ref.value' <<<"$repo_json")"
          sync_reference_repo "$name" "$path" "$url" "$ref_type" "$ref_value"
        done < <($jq_bin -c '.repos[]' "$config_file")
      '';
      description = "Clone or update reference repos listed in config/reference-repos.json into .repos/.";
      binary = "bash";
    };
    "clone:repos:status" = {
      exec = ''
                set -euo pipefail
                config_file="$DEVENV_ROOT/config/reference-repos.json"
                jq_bin="${pkgs.jq}/bin/jq"
                status=0

                while IFS= read -r repo_json; do
                  name="$($jq_bin -r '.name' <<<"$repo_json")"
                  path="$($jq_bin -r '.path' <<<"$repo_json")"
                  ref_type="$($jq_bin -r '.ref.type' <<<"$repo_json")"
                  ref_value="$($jq_bin -r '.ref.value' <<<"$repo_json")"
                  dest="$DEVENV_ROOT/$path"

                  if [ ! -d "$dest/.git" ]; then
                    echo "MISSING  $path ($ref_type:$ref_value)"
                    status=1
                    continue
                  fi

                  git -C "$dest" fetch origin --tags --quiet >/dev/null 2>&1 || true
                  head_short="$(git -C "$dest" rev-parse --short HEAD)"

                  case "$ref_type" in
                    branch)
                      if git -C "$dest" show-ref --verify --quiet "refs/remotes/origin/$ref_value"; then
                        read -r ahead behind <<EOF
        $(git -C "$dest" rev-list --left-right --count "HEAD...origin/$ref_value")
        EOF
                        if [ "$ahead" -eq 0 ] && [ "$behind" -eq 0 ]; then
                          echo "OK       $path @ $head_short (branch $ref_value in sync)"
                        else
                          echo "DRIFT    $path @ $head_short (branch $ref_value ahead=$ahead behind=$behind)"
                          status=1
                        fi
                      else
                        echo "UNKNOWN  $path @ $head_short (missing origin/$ref_value)"
                        status=1
                      fi
                      ;;
                    tag)
                      expected_commit="$(git -C "$dest" rev-list -n 1 "$ref_value")"
                      current_commit="$(git -C "$dest" rev-parse HEAD)"
                      if [ "$current_commit" = "$expected_commit" ]; then
                        echo "OK       $path @ $head_short (tag $ref_value)"
                      else
                        echo "DRIFT    $path @ $head_short (expected tag $ref_value -> ''${expected_commit:0:7})"
                        status=1
                      fi
                      ;;
                    commit)
                      current_commit="$(git -C "$dest" rev-parse HEAD)"
                      if [ "$current_commit" = "$(git -C "$dest" rev-parse "$ref_value^{commit}")" ]; then
                        echo "OK       $path @ $head_short (commit $ref_value)"
                      else
                        echo "DRIFT    $path @ $head_short (expected commit $ref_value)"
                        status=1
                      fi
                      ;;
                  esac
                done < <($jq_bin -c '.repos[]' "$config_file")

                exit "$status"
      '';
      description = "Report whether cloned reference repos match config/reference-repos.json.";
      binary = "bash";
    };
    "update:deps" = {
      exec = ''
        set -euo pipefail
        devenv update
        flutter pub upgrade
        install:all
      '';
      description = "Update devenv and pub dependencies, then resync workspace versions.";
      binary = "bash";
    };
  };
}
