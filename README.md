# lsfg-vk-nix

Nix package for [lsfg-vk](https://github.com/PancakeTAS/lsfg-vk) — Vulkan frame generation using Lossless Scaling on Linux.

## What's Included

- **lsfg-vk** — Implicit Vulkan layer for frame generation
- **lsfg-vk-ui** — Qt6/QML graphical configuration (per-game profiles)
- **lsfg-vk-cli** — CLI for benchmarking and config validation

## Requirements

- [Lossless Scaling](https://store.steampowered.com/app/993090/Lossless_Scaling/) (Steam)
- Vulkan-capable GPU

## Usage (Flake)

```nix
{
  inputs.lsfg-vk.url = "github:daaboulex/lsfg-vk-nix";
  inputs.lsfg-vk.inputs.nixpkgs.follows = "nixpkgs";
}
```

Add the overlay:
```nix
nixpkgs.overlays = [ inputs.lsfg-vk.overlays.default ];
```

Then add to packages:
```nix
environment.systemPackages = [ pkgs.lsfg-vk ];
```

## License

- **Packaging (this repo)**: MIT
- **lsfg-vk (upstream)**: GPL-3.0
