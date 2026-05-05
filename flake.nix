{
  description = "Lossless Scaling Frame Generation for Linux (Vulkan layer + UI)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      git-hooks,
    }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      overlays.default = final: prev: {
        lsfg-vk = final.callPackage ./package.nix { };
      };

      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            localSystem.system = system;
          };
        in
        {
          lsfg-vk = pkgs.callPackage ./package.nix { };
          default = self.packages.${system}.lsfg-vk;
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      checks = forAllSystems (system: {
        pre-commit-check = git-hooks.lib.${system}.run {
          src = self;
          hooks.nixfmt-rfc-style.enable = true;
            hooks.typos.enable = true;
            hooks.rumdl.enable = true;
            hooks.check-readme-sections = {
              enable = true;
              name = "check-readme-sections";
              entry = "bash scripts/check-readme-sections.sh";
              files = "README\.md$";
              language = "system";
            };
        };
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            inherit (self.checks.${system}.pre-commit-check) shellHook;
            buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
            packages = with pkgs; [ nil ];
          };
        }
      );

      apps = forAllSystems (system: {
        lsfg-vk-ui = {
          type = "app";
          program = "${self.packages.${system}.lsfg-vk}/bin/lsfg-vk-ui";
        };
        lsfg-vk-cli = {
          type = "app";
          program = "${self.packages.${system}.lsfg-vk}/bin/lsfg-vk-cli";
        };
        default = self.apps.${system}.lsfg-vk-ui;
      });
    };
}
