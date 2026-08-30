{
  lib,
  clangStdenv,
  fetchgit,
  cmake,
  pkg-config,
  makeWrapper,
  vulkan-headers,
  vulkan-loader,
  qt6,
}:

# Built with clang, not the default gcc. Upstream builds with clang (its
# cmake/Diagnostics.cmake only wires clang-tidy for Clang), and gcc 15 rejects
# hooks.cpp's brace-init of vk::Extent2D as ambiguous against three operator=
# candidates in their VENDORED thirdparty/vulkan/vulkan.hpp. Switching our
# toolchain is the only fix available: the CC BY-NC-ND licence forbids
# derivative works, so patching their source is not permitted.
clangStdenv.mkDerivation rec {
  pname = "lsfg-vk";
  version = "2.0.0-rc1-unstable-2026-08-29";

  # Upstream left GitHub on 2026-08-27; the GitHub repo is frozen at a migration
  # notice and its source was removed. The advertised Codeberg mirror is not
  # syncing (still at its initial commit), so this self-hosted remote is the only
  # live source. The cgit web path is NOT cloneable; the .git suffix is.
  src = fetchgit {
    url = "https://git.lsfg-vk.dev/lsfg-vk.git";
    rev = "9d10aae00bcc3fa3ed0f86d602b67c35011d47a2";
    hash = "sha256-K0eFiEJo5qMFwMzVFqV0e3c+ktPWO3o89R/bIz37PFg=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    vulkan-headers
    vulkan-loader
    qt6.qtbase
    qt6.qtdeclarative
  ];

  # v2 renamed LSFGVK_BUILD_VK_LAYER and dropped LSFGVK_INSTALL_XDG_FILES; the
  # old names would be accepted silently as unused cache entries and build the
  # wrong thing. LSFGVK_MANAGED is upstream's own flag for distro packaging.
  cmakeFlags = [
    "-DLSFGVK_BUILD_LAYER=ON"
    "-DLSFGVK_BUILD_UI=ON"
    "-DLSFGVK_BUILD_CLI=ON"
    "-DLSFGVK_MANAGED=ON"
    "-DLSFGVK_LAYER_LIBRARY_PATH=${placeholder "out"}/lib/liblsfg-vk-layer.so"
  ];

  # Prevent wrapQtAppsHook from auto-wrapping all binaries —
  # the CLI doesn't use Qt and shouldn't get Qt env vars
  dontWrapQtApps = true;

  postFixup = ''
    # Wrap UI with Qt environment + Vulkan loader
    wrapQtApp $out/bin/lsfg-vk-ui \
      --prefix LD_LIBRARY_PATH : "${vulkan-loader}/lib"

    # Wrap CLI with just Vulkan loader (no Qt needed)
    wrapProgram $out/bin/lsfg-vk-cli \
      --prefix LD_LIBRARY_PATH : "${vulkan-loader}/lib"
  '';

  meta = with lib; {
    description = "Vulkan frame generation layer using Lossless Scaling (requires owning Lossless Scaling on Steam)";
    longDescription = ''
      lsfg-vk is a Vulkan layer that hooks into Vulkan applications and generates
      additional frames using Lossless Scaling's frame generation algorithm.
      Works with native Linux games and Windows games via Wine/Proton.

      Includes:
      - lsfg-vk: Implicit Vulkan layer for frame generation
      - lsfg-vk-ui: Qt6/QML graphical configuration interface with per-game profiles
      - lsfg-vk-cli: Command-line tool for benchmarking and config validation
    '';
    homepage = "https://lsfg-vk.dev";
    # Relicensed from GPLv3 on 2026-08-27. CC BY-NC-ND is not a free licence:
    # NonCommercial and NoDerivatives both fail the FSF criteria, so nixpkgs
    # marks it unfree and it needs allowUnfree. NoDerivatives is also why this
    # derivation must never patch the source -- a patched build is a derivative.
    license = licenses.cc-by-nc-nd-40;
    platforms = lib.platforms.linux;
    mainProgram = "lsfg-vk-ui";
    maintainers = [
      {
        name = "Daaboulex";
        github = "Daaboulex";
        githubId = 39669593;
      }
    ];
  };
}
