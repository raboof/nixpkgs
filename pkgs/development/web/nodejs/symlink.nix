{
  lib,
  nodejs-slim,
  symlinkJoin,
}:
symlinkJoin {
  pname = "nodejs";
  inherit (nodejs-slim) version meta;
  passthru = nodejs-slim.passthru // {
    src = nodejs-slim.src;
  };
  paths = [
    nodejs-slim
    nodejs-slim.npm
  ]
  ++ lib.optional (builtins.hasAttr "corepack" nodejs-slim) nodejs-slim.corepack;
}
