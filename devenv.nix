{
  pkgs,
  lib,
  config,
  ...
}:

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
    "knope" = {
      exec = ''
        set -e
        $DEVENV_ROOT/.eget/bin/knope $@
      '';
      description = "The knope executable for changeset and release management.";
      binary = "bash";
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
        melos exec -- dart fix --apply
      '';
      description = "Fix lint issues across all packages.";
      binary = "bash";
    };
    "lint:all" = {
      exec = ''
        set -e
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
        melos analyze
      '';
      description = "Run dart analyze across all packages.";
      binary = "bash";
    };
    "test:all" = {
      exec = ''
        set -e
        melos test
      '';
      description = "Run all tests via melos.";
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
