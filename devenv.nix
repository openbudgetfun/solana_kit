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
      curl
      dprint
      eget
      fvm
      libiconv
      nixfmt
      nushell
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

  enterShell = ''
    set -e
    export PATH="$DEVENV_ROOT/.eget/bin:$PATH";
  '';

  scripts = {
    "flutter" = {
      exec = ''
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
      '';
      description = "Run all install scripts.";
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
