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
      eget
      fvm
      gitleaks
      libiconv
      nixfmt
      shfmt
      extra.knope
      extra.mdt
      extra.pnpm-standalone
    ]
    ++ lib.optionals stdenv.isDarwin [
      coreutils
    ];

  dotenv.disableHint = true;

  # Rely on the global sdk for now as the nix apple sdk is not working for me.
  apple.sdk = null;

  env = {
    EGET_CONFIG = "${config.env.DEVENV_ROOT}/.eget/.eget.toml";
  };

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
        install:eget
        install:dart
      '';
      description = "Run all install scripts.";
      binary = "bash";
    };
    "install:dart" = {
      exec = ''
        set -e
        dart pub get
        flutter pub get
      '';
      description = "Install dart dependencies";
      binary = "bash";
    };
    "install:eget" = {
      exec = ''
        HASH=$(nix hash path --base32 ./.eget/.eget.toml)
        echo "HASH: $HASH"
        if [ ! -f ./.eget/bin/hash ] || [ "$HASH" != "$(cat ./.eget/bin/hash)" ]; then
          echo "Updating eget binaries"
          eget -D --to "$DEVENV_ROOT/.eget/bin"
          echo "$HASH" > ./.eget/bin/hash
        else
          echo "eget binaries are up to date"
        fi
      '';
      description = "Install github binaries with eget.";
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
      '';
      description = "Fix formatting for entire project.";
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
    "sync:check" = {
      exec = ''
        set -e
        $DEVENV_ROOT/scripts/sync-workspace-dependency-versions.sh --check
        $DEVENV_ROOT/scripts/sync-package-changelogs.sh --check
      '';
      description = "Check packages sync.";
      binary = "bash";
    };
    "docs:check" = {
      exec = ''
        set -e
        mdt check
        scripts/workspace-doc-drift.sh --check
      '';
      description = "Check documentation consistency with mdt and workspace metadata.";
      binary = "bash";
    };
    "docs:update" = {
      exec = ''
        set -e
        mdt update
        scripts/workspace-doc-drift.sh --write
      '';
      description = "Update generated documentation blocks across the workspace.";
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
          if ! dart test "$pkg_dir"; then
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

        if [ "$failed" -ne 0 ]; then
          echo "Some tests failed."
          exit 1
        fi
      '';
      description = "Run all tests across workspace packages.";
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
        dart run coverage:test_with_coverage -- "''${test_dirs[@]}"
      '';
      description = "Generate merged LCOV coverage for all packages.";
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
      '';
      description = "Update devenv and pub dependencies.";
      binary = "bash";
    };
  };
}
