# lsfg-vk (Nix)

A Nix package of [lsfg-vk](https://lsfg-vk.dev), created and maintained by
[PancakeTAS](https://lsfg-vk.dev) with its upstream contributors. It generates
extra frames in Vulkan games on Linux with the frame generation of
[Lossless Scaling](https://store.steampowered.com/app/993090/Lossless_Scaling/)
by THS. It is for people who own Lossless Scaling on Steam, and it covers
native Linux games and Windows games run through Wine or Proton.

The flake is set up for `x86_64-linux` and `aarch64-linux`, on nixos-unstable.
Its checks build the package and confirm that `lsfg-vk-ui` is in the result.
Nothing in this repository runs the layer in a game, so no GPU, game or machine
is recorded here as tried.

## What you get

One package, `lsfg-vk`, built from upstream source, with three parts:

- The Vulkan layer. It is an implicit layer, so it loads for any Vulkan game.
  You enable it per game, in the UI or through environment variables.
- `lsfg-vk-ui`, a graphical configuration program with per-game profiles.
- `lsfg-vk-cli`, a command-line tool for benchmarking and for validating the
  configuration.

Lossless Scaling itself is not in this flake and is not redistributed by it.
lsfg-vk reads the Lossless Scaling DLL from your Steam install at runtime.

## What you need

- [Lossless Scaling](https://store.steampowered.com/app/993090/Lossless_Scaling/),
  installed through Steam.
- A Vulkan-capable GPU (AMD RADV, NVIDIA, Intel).

## Install

Add the flake:

```nix
{
  inputs.lsfg-vk = {
    url = "github:Daaboulex/lsfg-vk-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Then add the overlay, allow the package and install it:

```nix
{
  nixpkgs.overlays = [ inputs.lsfg-vk.overlays.default ];
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "lsfg-vk" ];
  environment.systemPackages = [ pkgs.lsfg-vk ];
}
```

lsfg-vk is unfree, so nixpkgs refuses `pkgs.lsfg-vk` from the overlay until you
allow it. The second line allows only this package.
`nixpkgs.config.allowUnfree = true;` allows every unfree package instead.

Unfree is about freedom, not price. The licence is gratis and anyone may
download and use lsfg-vk.

To try it without installing:

```bash
nix run github:Daaboulex/lsfg-vk-nix
nix run github:Daaboulex/lsfg-vk-nix#lsfg-vk-cli
```

The first starts the UI, the second the CLI. Neither needs the unfree setting,
because the flake's own packages already allow it.

## Use

Start `lsfg-vk-ui` from your application menu or a terminal:

```bash
lsfg-vk-ui
```

| Section in the UI | What you set there |
|---|---|
| Profile Settings | The per-game profiles |
| Global Settings | The Lossless Scaling install path, auto-detected for Steam |

The layer then activates on its own for any game that matches a profile.

The CLI has two commands to start with:

```bash
lsfg-vk-cli benchmark
lsfg-vk-cli validate
```

The first runs a benchmark. The second validates your configuration.

## Known limits

- You need your own copy of Lossless Scaling on Steam. This flake does not
  ship it.
- This package never patches lsfg-vk. A fix to its source has to come from
  upstream.

## When something does not work

Check the configuration first:

```bash
lsfg-vk-cli validate
```

To run one program without the layer:

```bash
DISABLE_LSFGVK=1 your-application
```

## More

- [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md): building, the checks, how the
  pinned upstream commit is updated
- [SECURITY.md](SECURITY.md): how to report a vulnerability

## License

The Nix packaging in this repository is [MIT](LICENSE).

lsfg-vk (upstream) is
[CC BY-NC-ND 4.0](https://git.lsfg-vk.dev/lsfg-vk/plain/LICENSE.txt).
NonCommercial and NoDerivatives both fail the FSF criteria, so nixpkgs marks
this unfree. NoDerivatives also means this package must never patch upstream
source: a patched build is a derivative work. It builds with clang because
gcc 15 rejects `hooks.cpp`, and changing the toolchain is permitted where
changing their source is not.
