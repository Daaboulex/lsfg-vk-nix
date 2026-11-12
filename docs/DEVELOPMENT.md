# Development

## Commands

| Command | What it does |
|---|---|
| `nix develop` | Enters the dev shell, which installs the pre-commit hooks |
| `nix flake check --no-build` | Evaluates the flake without building, which is fast |
| `nix build` | Builds the package |
| `nix fmt` | Formats the Nix files with nixfmt |

CI runs on every push to `main` and on pull requests, from
[.github/workflows/ci.yml](../.github/workflows/ci.yml).

## The checks this repository adds

Both are defined in [flake.nix](../flake.nix), next to the shared checks that
come from the packaging standard.

`no-derivative-works` reads [package.nix](../package.nix) and fails when any of
these stops holding:

- The package does not patch the source. No `patches`, `postPatch`, `prePatch`
  or `substituteInPlace`. lsfg-vk is CC BY-NC-ND 4.0, and NoDerivatives means a
  modified build may not be distributed.
- It builds with `clangStdenv`. gcc 15 rejects `hooks.cpp`, and the licence
  rules out patching it, so the toolchain is what changes.
- The licence is `licenses.cc-by-nc-nd-40`.
- The source is named as `git.lsfg-vk.dev`.

`smoke` confirms that `bin/lsfg-vk-ui` exists in the built package and is
executable. The package is a Vulkan layer and a Qt6 UI, with no headless
binary to run, so the check stops there.

## How the package is updated

The package tracks git commits on the `master` branch of
`https://git.lsfg-vk.dev/lsfg-vk.git`. That self-hosted remote is the live
source. The project page is [lsfg-vk.dev](https://lsfg-vk.dev) and the source
can be browsed at [git.lsfg-vk.dev](https://git.lsfg-vk.dev/lsfg-vk). Only the
URL with the `.git` suffix can be cloned.

A daily GitHub Actions workflow,
[.github/workflows/update.yml](../.github/workflows/update.yml), detects new
commits with `git ls-remote`. It recomputes the hash and rebuilds. On success
it commits to `main`. On failure it opens an issue.

What the workflow follows is declared in
[.github/update.json](../.github/update.json).
