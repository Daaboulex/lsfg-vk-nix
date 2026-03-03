{
  description = "Lossless Scaling Frame Generation for Linux (Vulkan layer + UI)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: let
    systems = [ "x86_64-linux" ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    overlays.default = final: prev: {
      lsfg-vk = final.callPackage ./package.nix { };
    };

    packages = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      lsfg-vk = pkgs.callPackage ./package.nix { };
      default = self.packages.${system}.lsfg-vk;
    });

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
