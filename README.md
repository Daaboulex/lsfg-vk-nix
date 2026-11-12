# lsfg-vk-nix

<!-- BEGIN generated:badges -->
[![CI](https://github.com/Daaboulex/lsfg-vk-nix/actions/workflows/ci.yml/badge.svg)](https://github.com/Daaboulex/lsfg-vk-nix/actions/workflows/ci.yml)
[![NixOS unstable](https://img.shields.io/badge/NixOS-unstable-78C0E8?logo=nixos&logoColor=white)](https://nixos.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
<!-- END generated:badges -->

Nix package for [lsfg-vk](https://lsfg-vk.dev) by [PancakeTAS](https://lsfg-vk.dev) — Vulkan frame generation using [Lossless Scaling](https://store.steampowered.com/app/993090/Lossless_Scaling/) on Linux.

<!-- BEGIN generated:upstream -->
## Upstream

| | |
|---|---|
| **Project** | [lsfg-vk.dev](https://lsfg-vk.dev) (git: [git.lsfg-vk.dev](https://git.lsfg-vk.dev/lsfg-vk)) |
| **License** | CC BY-NC-ND 4.0 (unfree: the overlay's package needs `allowUnfree`) |
| **Tracked** | Git commits (`master` branch, via `git ls-remote`) |

<!-- END generated:upstream -->

## What Is This?

A Nix flake that builds the lsfg-vk Vulkan layer, UI and CLI from upstream source:

- **Implicit Vulkan layer** — auto-loads for any Vulkan game; per-game enable through environment variables or the GUI
- **Lossless Scaling integration** — pulls the Lossless Scaling DLL from the user's Steam install at runtime; this flake does NOT redistribute Lossless Scaling

## What's Included

The package holds the implicit Vulkan layer, `lsfg-vk-ui` and `lsfg-vk-cli`, each described in the `longDescription` of [package.nix](./package.nix).

## Requirements

- **[Lossless Scaling](https://store.steampowered.com/app/993090/Lossless_Scaling/)** installed via Steam
- Vulkan-capable GPU (AMD RADV, NVIDIA, Intel)
- **`allowUnfree` for `pkgs.lsfg-vk` from the overlay.** lsfg-vk is under
  CC BY-NC-ND 4.0, which nixpkgs classifies as unfree, so the overlay's package is
  refused unless your nixpkgs allows it. The flake's own packages (`nix build`,
  `nix run`) already allow it and need nothing.
  This is about freedom, not price: the licence is gratis and anyone may download and
  use lsfg-vk, but NonCommercial and NoDerivatives fail the FSF criteria.

  Allow it globally:

  ```nix
  nixpkgs.config.allowUnfree = true;
  ```

  Or allow only this package:

  ```nix
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "lsfg-vk" ];
  ```

<!-- BEGIN generated:installation -->
## Installation

Add as a flake input:

```nix
{
  inputs.lsfg-vk = {
    url = "github:Daaboulex/lsfg-vk-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Then add the overlay:

```nix
nixpkgs.overlays = [ inputs.lsfg-vk.overlays.default ];
```

<!-- END generated:installation -->

## Usage

### As a Flake Input

```nix
{
  inputs.lsfg-vk = {
    url = "github:daaboulex/lsfg-vk-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Add the overlay to your system configuration:

```nix
nixpkgs.overlays = [ inputs.lsfg-vk.overlays.default ];
```

Then add to your packages:

```nix
environment.systemPackages = [ pkgs.lsfg-vk ];
```

### Quick Test (without installing)

```bash
nix run github:daaboulex/lsfg-vk-nix        # Launch the UI
nix run github:daaboulex/lsfg-vk-nix#lsfg-vk-cli  # Launch the CLI
```

## Configuration

After installation, launch `lsfg-vk-ui` from your application menu or terminal:

```bash
lsfg-vk-ui
```

- Configure per-game profiles in the **Profile Settings** section.
- Set the Lossless Scaling install path in **Global Settings** (auto-detected for Steam).
- Run benchmarks with `lsfg-vk-cli benchmark`.
- Validate your config with `lsfg-vk-cli validate`.

The Vulkan layer activates automatically for any game matching a configured profile.

To disable the layer for a specific application:

```bash
DISABLE_LSFGVK=1 your-application
```

## Updates

This package tracks the `master` branch of the upstream git repository at
`https://git.lsfg-vk.dev/lsfg-vk.git`. A daily GitHub Actions workflow detects new
commits via `git ls-remote`, recomputes the hash, rebuilds, and commits to `main` on
success (or opens an issue on failure).

The self-hosted remote at `git.lsfg-vk.dev` is the live source, and the
`no-derivative-works` check fails if [package.nix](./package.nix) fetches from
anywhere else.

## Development

```bash
nix develop                  # dev shell with pre-commit hooks
nix flake check --no-build   # eval check (fast)
nix build                    # build package
nix fmt                      # format (nixfmt-rfc-style)
```

## Credits

- **[PancakeTAS](https://lsfg-vk.dev)** — Creator and maintainer of lsfg-vk
- **[Lossless Scaling](https://store.steampowered.com/app/993090/Lossless_Scaling/)** by THS
- All upstream contributors

## License

- **Nix packaging (this repo)**: [MIT](LICENSE)
- **lsfg-vk (upstream)**: [CC BY-NC-ND 4.0](https://git.lsfg-vk.dev/lsfg-vk/plain/LICENSE.txt).
  NonCommercial and NoDerivatives both fail
  the FSF criteria, so nixpkgs marks this unfree. NoDerivatives also means this
  package must never patch upstream source: a patched build is a derivative work.
  It builds with clang because gcc 15 rejects `hooks.cpp`, and changing the
  toolchain is permitted where changing their source is not.

<!-- BEGIN generated:footer -->
<!-- END generated:footer -->
