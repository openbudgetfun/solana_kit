{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  extra = inputs.ifiokjr-nixpkgs.packages.${pkgs.stdenv.system};
in
{
  packages =
    with pkgs;
    [
      dprint
      fvm
      gitleaks
      ktlint
      libiconv
      nixfmt
      osv-scanner
      shfmt
      extra.knope
      extra.mdt
      extra.surfpool
      (extra.pnpm-standalone.overrideAttrs { doInstallCheck = false; })
    ]
    ++ lib.optionals stdenv.isDarwin [
      coreutils
    ];

  enterShell = ''
    eval "$(pnpm-activate-env)"
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
      format = {
        enable = true;
        name = "format";
        description = "Format files with dprint before commit.";
        entry = "${pkgs.dprint}/bin/dprint fmt --allow-no-files";
        stages = [ "pre-commit" ];
      };
      lint = {
        enable = true;
        name = "lint";
        description = "Run linting and formatting checks on every commit.";
        entry = "${config.env.DEVENV_PROFILE}/bin/dart analyze --fatal-infos";
        pass_filenames = true;
        always_run = true;
        stages = [ "pre-commit" ];
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
        set -e
        fvm flutter $@
      '';
      description = "Run flutter commands.";
    };
    "dart" = {
      exec = ''
        set -e
        fvm dart $@
      '';
      description = "Run dart commands.";
    };
    "melos" = {
      exec = ''
        set -e
        dart run melos $@
      '';
      description = "Run the melos cli.";
    };
    "jaspr" = {
      exec = ''
        set -e
        dart run jaspr_cli:jaspr $@
      '';
      description = "Run the jaspr cli.";
    };
    "format_coverage" = {
      exec = ''
        set -e
        dart run coverage:format_coverage $@
      '';
      description = "Run the format_coverage command from the coverage package.";
    };
    "dartfmt" = {
      exec = ''
        set -e
        dart format -o show $@ | head -n -1
      '';
      description = "The dart format executable for formatting the workspace.";
      binary = "bash";
    };
    "install:all" = {
      exec = ''
        set -e
        install:dart
      '';
      description = "Run all install scripts.";
      binary = "bash";
    };
    "install:dart" = {
      exec = ''
        set -e
        flutter pub get
      '';
      description = "Install dart dependencies";
      binary = "bash";
    };
    "fix:all" = {
      exec = ''
        set -e
        sync:write
        docs:update
        fix:format
        fix:lint
      '';
      description = "Fix all fixable issues.";
      binary = "bash";
    };
    "fix:format" = {
      exec = ''
        set -e
        dprint fmt --config "$DEVENV_ROOT/dprint.json"

        mapfile -t kotlin_files < <(git ls-files '*.kt' '*.kts')
        if [ ''${#kotlin_files[@]} -gt 0 ]; then
          ktlint --relative --format "''${kotlin_files[@]}"
        else
          echo "No Kotlin files found for ktlint formatting."
        fi
      '';
      description = "Fix formatting for entire project.";
      binary = "bash";
    };
    "fix:lint" = {
      exec = ''
        set -e
        dart fix --apply
      '';
      description = "Fix lint issues across all packages.";
      binary = "bash";
    };
    "sync:write" = {
      exec = ''
        set -e
        $DEVENV_ROOT/scripts/sync-workspace-dependency-versions.sh --write
        $DEVENV_ROOT/scripts/sync-package-changelogs.sh --write
      '';
      description = "Sync packages.";
      binary = "bash";
    };
    "lint:all" = {
      exec = ''
        set -e
        sync:check
        docs:check
        lint:format
        lint:kotlin
        lint:analyze
      '';
      description = "Run all lint checks.";
      binary = "bash";
    };
    "lint:format" = {
      exec = ''
        set -e
        dprint check
      '';
      description = "Check all formatting is correct.";
    };
    "lint:analyze" = {
      exec = ''
        set -e
        dart analyze --fatal-infos .
      '';
      description = "Run dart analyze across all packages.";
      binary = "bash";
    };
    "lint:kotlin" = {
      exec = ''
        set -e

        mapfile -t kotlin_files < <(git ls-files '*.kt' '*.kts')
        if [ ''${#kotlin_files[@]} -gt 0 ]; then
          ktlint --relative "''${kotlin_files[@]}"
        else
          echo "No Kotlin files found for ktlint linting."
        fi
      '';
      description = "Lint tracked Kotlin files with ktlint.";
      binary = "bash";
    };
    "sync:check" = {
      exec = ''
        set -e
        $DEVENV_ROOT/scripts/sync-workspace-dependency-versions.sh --check
        $DEVENV_ROOT/scripts/sync-package-changelogs.sh --check
      '';
      description = "Check packages sync.";
      binary = "bash";
    };
    "mdt:info" = {
      exec = ''
        set -e
        mkdir -p .mdt/cache
        mdt info
      '';
      description = "Inspect discovered mdt providers/consumers and cache reuse telemetry.";
      binary = "bash";
    };
    "mdt:doctor" = {
      exec = ''
        set -e
        mkdir -p .mdt/cache
        mdt doctor --format text
      '';
      description = "Run mdt health checks with actionable remediation hints.";
      binary = "bash";
    };
    "docs:check" = {
      exec = ''
        set -e
        mkdir -p .mdt/cache
        mdt check --verbose
        python3 "$DEVENV_ROOT/scripts/sync-dart-doc-comments.py" --check
        mdt doctor --format text
        scripts/workspace-doc-drift.sh --check
      '';
      description = "Check documentation consistency with mdt, synchronized Dart doc comments, and workspace metadata.";
      binary = "bash";
    };
    "docs:update" = {
      exec = ''
        set -e
        mkdir -p .mdt/cache
        mdt update --verbose
        python3 "$DEVENV_ROOT/scripts/sync-dart-doc-comments.py" --write
        scripts/workspace-doc-drift.sh --write
        mdt info
      '';
      description = "Update generated documentation blocks across Markdown and Dart doc comments, then print mdt diagnostics.";
      binary = "bash";
    };
    "docs:site:serve" = {
      exec = ''
        set -e
        cd "$DEVENV_ROOT/docs/site"
        flutter pub get
        fvm dart run jaspr_cli:jaspr serve "$@"
      '';
      description = "Serve the Jaspr documentation site locally.";
      binary = "bash";
    };
    "docs:site:build" = {
      exec = ''
        set -e
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
        set -e
        "$DEVENV_ROOT/scripts/docs-site-smoke.sh" "$@"
      '';
      description = "Run smoke tests against the built documentation site.";
      binary = "bash";
    };
    "upstream:check" = {
      exec = ''
        set -e
        "$DEVENV_ROOT/scripts/check-upstream-compatibility.sh" "$@"
      '';
      description = "Check tracked upstream compatibility metadata and local drift.";
      binary = "bash";
    };
    "upstream:parity" = {
      exec = ''
        set -e
        "$DEVENV_ROOT/scripts/check-upstream-parity.sh" "$@"
      '';
      description = "Generate runtime fixtures from the tracked @solana/kit release and compare selected behaviors against this Dart port.";
      binary = "bash";
    };
    "audit:deps" = {
      exec = ''
        set -e

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
        set -e
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
    "test:all" = {
      exec = ''
        set -e
        failed=0
        for pkg_dir in packages/*/; do
          if [ ! -d "$pkg_dir/test" ]; then
            continue
          fi

          # Skip Flutter packages (they need flutter test)
          if grep -q "flutter:" "$pkg_dir/pubspec.yaml" 2>/dev/null; then
            continue
          fi

          pkg_name="$(basename "$pkg_dir")"
          echo "Testing $pkg_name..."
          if ! dart test --exclude-tags integration "$pkg_dir"; then
            failed=1
          fi
        done

        # Also test generated packages under codama renderers
        for pkg_dir in packages/codama-renderers-dart/test-generated/; do
          if [ -d "$pkg_dir/test" ]; then
            pkg_name="$(basename "$(dirname "$pkg_dir")")/test-generated"
            echo "Testing $pkg_name..."
            if ! dart test "$pkg_dir"; then
              failed=1
            fi
          fi
        done

        if [ -d test ]; then
          echo "Testing root workspace helpers..."
          if ! dart test test; then
            failed=1
          fi
        fi

        if [ "$failed" -ne 0 ]; then
          echo "Some tests failed."
          exit 1
        fi
      '';
      description = "Run all tests across workspace packages and root doc-comment checks.";
      binary = "bash";
    };
    "test:doc-snippets" = {
      exec = ''
        set -e
        dart test test/doc_comment_snippets_test.dart
      '';
      description = "Analyze synchronized Dart doc-comment snippets for compile-time drift.";
      binary = "bash";
    };
    "test:coverage" = {
      exec = ''
        set -e

        mapfile -t test_dirs < <(
          find packages -mindepth 2 -maxdepth 2 -type d -name test \
            | grep -v '^packages/solana_kit_mobile_wallet_adapter/test$' \
            | sort
        )

        if [ ''${#test_dirs[@]} -eq 0 ]; then
          echo "No package test directories were found."
          exit 1
        fi

        echo "Running coverage for ''${#test_dirs[@]} package test directories..."
        echo "Skipping packages/solana_kit_mobile_wallet_adapter/test (requires flutter test)."
        dart run coverage:test_with_coverage -- --exclude-tags integration "''${test_dirs[@]}"
      '';
      description = "Generate merged LCOV coverage for all packages.";
      binary = "bash";
    };
    "coverage:check" = {
      exec = ''
        set -e
        python3 "$DEVENV_ROOT/scripts/check-risk-tier-coverage.py"
      '';
      description = "Run package-level coverage for risk-tier packages and enforce configured line-coverage floors.";
      binary = "bash";
    };
    "clone:repos" = {
      exec = ''
        set -e
        mkdir -p "$DEVENV_ROOT/.repos"

        if [ -d "$DEVENV_ROOT/.repos/kit" ]; then
          echo "Updating .repos/kit..."
          cd "$DEVENV_ROOT/.repos/kit" && git pull --ff-only
        else
          echo "Cloning anza-xyz/kit..."
          git clone https://github.com/anza-xyz/kit "$DEVENV_ROOT/.repos/kit"
        fi

        if [ -d "$DEVENV_ROOT/.repos/espresso-cash-public" ]; then
          echo "Updating .repos/espresso-cash-public..."
          cd "$DEVENV_ROOT/.repos/espresso-cash-public" && git pull --ff-only
        else
          echo "Cloning brij-digital/espresso-cash-public..."
          git clone https://github.com/brij-digital/espresso-cash-public "$DEVENV_ROOT/.repos/espresso-cash-public"
        fi
      '';
      description = "Clone or update reference repos into .repos/.";
      binary = "bash";
    };
    "update:deps" = {
      exec = ''
        set -e
        devenv update
        flutter pub upgrade
        sync:write
        install:all
      '';
      description = "Update devenv and pub dependencies, then resync workspace versions.";
      binary = "bash";
    };
  };
}
