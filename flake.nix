{
  description = "Lossless Scaling Frame Generation for Linux (Vulkan layer + UI)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    std = {
      url = "github:Daaboulex/nix-packaging-standard?ref=v2.32.1";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.git-hooks.follows = "git-hooks";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [ inputs.std.flakeModules.base ];

      perSystem =
        { system, self', ... }:
        let
          # lsfg-vk is unfree since upstream relicensed to CC BY-NC-ND on
          # 2026-08-27, so the default nixpkgs instance refuses to evaluate it and
          # every build here (CI included) fails before it starts.
          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          # "nd" is a real word to typos ("and"), but it is load-bearing here: the
          # nixpkgs licence attribute is literally licenses.cc-by-nc-nd-40 and the
          # licence is named CC BY-NC-ND. Neither can be spelled differently.
          pre-commit.settings.hooks.typos.settings.config.default.extend-words = {
            nd = "nd";
            ND = "ND";
          };

          packages.lsfg-vk = pkgs.callPackage ./package.nix { };
          packages.default = self'.packages.lsfg-vk;

          # Vulkan layer + Qt6 UI: no headless binary to run (update.json
          # verify = elf); the smoke check asserts the UI binary is present.
          # CC BY-NC-ND 4.0 forbids derivative works, so a patched build is not
          # licensed. gcc 15 rejects hooks.cpp, which is why this builds with
          # clang: the toolchain is ours to choose, their source is not ours to
          # modify. If that is ever "fixed" with a patch, this fails.
          checks.no-derivative-works =
            pkgs.runCommand "no-derivative-works" { packageFile = ./package.nix; }
              ''
                if grep -qE '^[[:space:]]*(patches|postPatch|prePatch)[[:space:]]*=|substituteInPlace' "$packageFile"; then
                  echo "package.nix patches the source. lsfg-vk is CC BY-NC-ND 4.0: NoDerivatives means a modified build may not be distributed. Change the toolchain or dependencies instead, or take it upstream"
                  exit 1
                fi

                grep -Fq 'clangStdenv.mkDerivation' "$packageFile" \
                  || { echo "not building with clang. gcc 15 fails on hooks.cpp vk::Extent2D brace-init (3 ambiguous operator= candidates in the VENDORED thirdparty vulkan.hpp), and patching it is not permitted by the licence"; exit 1; }

                grep -Fq 'licenses.cc-by-nc-nd-40' "$packageFile" \
                  || { echo "licence is not cc-by-nc-nd-40; upstream relicensed from GPLv3 on 2026-08-27 and this is unfree"; exit 1; }

                grep -Fq 'git.lsfg-vk.dev' "$packageFile" \
                  || { echo "source is not the live upstream. The GitHub repo was emptied on 2026-08-27 and is frozen at a migration notice; the Codeberg mirror is not syncing"; exit 1; }

                touch $out
              '';

          checks.smoke = pkgs.runCommand "lsfg-vk-smoke" { } ''
            test -x ${self'.packages.lsfg-vk}/bin/lsfg-vk-ui
            touch "$out"
          '';

          apps.lsfg-vk-ui = {
            type = "app";
            program = "${self'.packages.lsfg-vk}/bin/lsfg-vk-ui";
            meta.description = "Configuration UI for the lsfg-vk Lossless Scaling frame-generation Vulkan layer";
          };
          apps.lsfg-vk-cli = {
            type = "app";
            program = "${self'.packages.lsfg-vk}/bin/lsfg-vk-cli";
            meta.description = "Command-line configurator for the lsfg-vk Lossless Scaling frame-generation Vulkan layer";
          };
          apps.default = self'.apps.lsfg-vk-ui;
        };

      flake.overlays.default = final: _prev: {
        lsfg-vk = final.callPackage ./package.nix { };
      };
    };
}
