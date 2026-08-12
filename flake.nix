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
      url = "github:Daaboulex/nix-packaging-standard?ref=v2.21.0";
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
        { pkgs, self', ... }:
        {
          packages.lsfg-vk = pkgs.callPackage ./package.nix { };
          packages.default = self'.packages.lsfg-vk;

          # Vulkan layer + Qt6 UI: no headless binary to run (update.json
          # verify = elf); the smoke check asserts the UI binary is present.
          checks.smoke = pkgs.runCommand "lsfg-vk-smoke" { } ''
            test -x ${self'.packages.lsfg-vk}/bin/lsfg-vk-ui
            touch "$out"
          '';

          apps.lsfg-vk-ui = {
            type = "app";
            program = "${self'.packages.lsfg-vk}/bin/lsfg-vk-ui";
          };
          apps.lsfg-vk-cli = {
            type = "app";
            program = "${self'.packages.lsfg-vk}/bin/lsfg-vk-cli";
          };
          apps.default = self'.apps.lsfg-vk-ui;
        };

      flake.overlays.default = final: _prev: {
        lsfg-vk = final.callPackage ./package.nix { };
      };
    };
}
