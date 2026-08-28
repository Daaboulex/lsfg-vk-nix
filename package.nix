{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  makeWrapper,
  vulkan-headers,
  vulkan-loader,
  qt6,
}:

stdenv.mkDerivation rec {
  pname = "lsfg-vk";
  version = "2.0.0-dev-unstable-2026-08-28";

  src = fetchFromGitHub {
    owner = "PancakeTAS";
    repo = "lsfg-vk";
    rev = "0213be9ff93121283ad46a27119f40ece0e6f301";
    hash = "sha256-1HfVRaExIhtD+yRgu0y1x02VVIT/lW1xm1oL7bxwoMA=";
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

  cmakeFlags = [
    "-DLSFGVK_BUILD_VK_LAYER=ON"
    "-DLSFGVK_BUILD_UI=ON"
    "-DLSFGVK_BUILD_CLI=ON"
    "-DLSFGVK_INSTALL_XDG_FILES=ON"
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
    homepage = "https://github.com/PancakeTAS/lsfg-vk";
    license = licenses.gpl3Only;
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
