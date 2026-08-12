# lsfg-vk-nix

<!-- BEGIN generated:badges -->
[![CI](https://github.com/Daaboulex/lsfg-vk-nix/actions/workflows/ci.yml/badge.svg)](https://github.com/Daaboulex/lsfg-vk-nix/actions/workflows/ci.yml)
[![NixOS unstable](https://img.shields.io/badge/NixOS-unstable-78C0E8?logo=nixos&logoColor=white)](https://nixos.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
<!-- END generated:badges -->

Nix package for [lsfg-vk](https://github.com/PancakeTAS/lsfg-vk) by [PancakeTAS](https://github.com/PancakeTAS) — Vulkan frame generation using [Lossless Scaling](https://store.steampowered.com/app/993090/Lossless_Scaling/) on Linux.

<!-- BEGIN generated:upstream -->
## Upstream

| | |
|---|---|
| **Project** | [PancakeTAS/lsfg-vk](https://github.com/PancakeTAS/lsfg-vk) |
| **License** | GPL-3.0 |
| **Tracked** | Git commits (develop branch) |

<!-- END generated:upstream -->

## What Is This?

A Nix flake that builds the lsfg-vk Vulkan layer + UI + CLI from upstream with full CI infrastructure:

- **Upstream tracking** daily via GitHub Actions — new commits are detected, rebuilt, and committed to `main`
- **Pre-build verification** — fail-closed pipeline (eval → build → ELF check) before any push to `main`
- **Implicit Vulkan layer** — auto-loads for any Vulkan game; per-game enable through environment variables or the GUI
- **Lossless Scaling integration** — pulls the Lossless Scaling DLL from the user's Steam install at runtime; this flake does NOT redistribute Lossless Scaling

## What's Included

| Component | Description |
|---|---|
| **lsfg-vk layer** | Implicit Vulkan layer that generates additional frames using Lossless Scaling's frame generation algorithm |
| **lsfg-vk-ui** | Qt6/QML graphical configuration interface with per-game profiles, flow scale controls, and performance mode |
| **lsfg-vk-cli** | Command-line tool for benchmarking and configuration validation |

## Requirements

- **[Lossless Scaling](https://store.steampowered.com/app/993090/Lossless_Scaling/)** installed via Steam
- Vulkan-capable GPU (AMD RADV, NVIDIA, Intel)

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

This package tracks the `develop` branch of [PancakeTAS/lsfg-vk](https://github.com/PancakeTAS/lsfg-vk). A daily GitHub Actions workflow detects new commits, recomputes the hash, rebuilds, and commits to `main` on success (or opens an issue on failure).

## Development

```bash
nix develop                  # dev shell with pre-commit hooks
nix flake check --no-build   # eval check (fast)
nix build                    # build package
nix fmt                      # format (nixfmt-rfc-style)
```

## Credits

- **[PancakeTAS](https://github.com/PancakeTAS)** — Creator and maintainer of lsfg-vk
- **[Lossless Scaling](https://store.steampowered.com/app/993090/Lossless_Scaling/)** by [TechPowerUp](https://www.techpowerup.com/)
- All upstream [contributors](https://github.com/PancakeTAS/lsfg-vk/graphs/contributors)

## License

- **Nix packaging (this repo)**: [MIT](LICENSE)
- **lsfg-vk (upstream)**: [GPL-3.0](https://github.com/PancakeTAS/lsfg-vk/blob/develop/LICENSE.md)

<!-- BEGIN generated:footer -->
<!-- END generated:footer -->
