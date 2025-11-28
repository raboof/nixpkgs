{
  fetchFromGitHub,
  qtModule,
  qtbase,
  qtlanguageserver,
  qtshadertools,
  qtsvg,
  openssl,
  darwin,
  stdenv,
  lib,
  pkgsBuildBuild,
  replaceVars,
}:

qtModule {
  pname = "qtdeclarative";

  src = fetchFromGitHub {
    owner = "raboof";
    repo = "qtdeclarative";
    # explicit-deps
    rev = "fb1f4937db81e57895baf259916bc615c5f3845e";
    hash = "sha256-ibLXw3IJ6pdoVvp2jbR2zoO1ABn5iopOt4tOMMXBFRE=";
  };
  propagatedBuildInputs = [
    qtbase
    qtlanguageserver
    qtshadertools
    qtsvg
    openssl
  ];
  strictDeps = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.sigtool
  ];

  patches = [
    # don't cache bytecode of bare qml files in the store, as that never gets cleaned up
    (replaceVars ./dont-cache-nix-store-paths.patch {
      nixStore = builtins.storeDir;
    })
    # add version specific QML import path
    ./use-versioned-import-path.patch
  ];

  cmakeFlags = [
    "-DQt6ShaderToolsTools_DIR=${pkgsBuildBuild.qt6.qtshadertools}/lib/cmake/Qt6ShaderTools"
    # for some reason doesn't get found automatically on Darwin
    "-DPython_EXECUTABLE=${lib.getExe pkgsBuildBuild.python3}"
  ]
  # Conditional is required to prevent infinite recursion during a cross build
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "-DQt6QmlTools_DIR=${pkgsBuildBuild.qt6.qtdeclarative}/lib/cmake/Qt6QmlTools"
  ];

  meta.maintainers = with lib.maintainers; [
    nickcao
    outfoxxed
  ];
}
