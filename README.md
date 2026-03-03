# lsfg-vk-nix

Nix package for [lsfg-vk](https://github.com/PancakeTAS/lsfg-vk) by [PancakeTAS](https://github.com/PancakeTAS) — Vulkan frame generation using [Lossless Scaling](https://store.steampowered.com/app/993090/Lossless_Scaling/) on Linux.

> **Disclaimer**: This repository only contains the Nix packaging scripts. All credit for lsfg-vk goes to [PancakeTAS](https://github.com/PancakeTAS) and the upstream contributors. The upstream project is licensed under [GPL-3.0](https://github.com/PancakeTAS/lsfg-vk/blob/develop/LICENSE.md).

## What's Included

| Component | Description |
|---|---|
| **lsfg-vk layer** | Implicit Vulkan layer that generates additional frames using Lossless Scaling's frame generation algorithm |
| **lsfg-vk-ui** | Qt6/QML graphical configuration interface with per-game profiles, flow scale controls, and performance mode |
| **lsfg-vk-cli** | Command-line tool for benchmarking and configuration validation |

## Requirements

- **[Lossless Scaling](https://store.steampowered.com/app/993090/Lossless_Scaling/)** installed via Steam
- Vulkan-capable GPU (AMD RADV, NVIDIA, Intel)

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

This package tracks the upstream `v2.0.0-dev` tag from [PancakeTAS/lsfg-vk](https://github.com/PancakeTAS/lsfg-vk). A GitHub Actions workflow automatically checks for new releases and updates the package hash.

## Credits

- **[PancakeTAS](https://github.com/PancakeTAS)** — Creator and maintainer of lsfg-vk
- **[Lossless Scaling](https://store.steampowered.com/app/993090/Lossless_Scaling/)** by [TechPowerUp](https://www.techpowerup.com/)
- All upstream [contributors](https://github.com/PancakeTAS/lsfg-vk/graphs/contributors)

## License

- **Nix packaging (this repo)**: [MIT](LICENSE)
- **lsfg-vk (upstream)**: [GPL-3.0](https://github.com/PancakeTAS/lsfg-vk/blob/develop/LICENSE.md)
