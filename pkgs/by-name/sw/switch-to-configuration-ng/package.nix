{
  buildPackages,
  clippy,
  dbus,
  lib,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "switch-to-configuration";
  version = "0.1.0";

  src = ./src;

  cargoLock.lockFile = ./src/Cargo.lock;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dbus ];

  postFixup = ''
    mv $out/bin/switch-to-configuration $out/bin/switch-wrapped
    cat >$out/bin/switch-to-configuration <<EOF;
#!/usr/bin/env sh

$out/bin/switch-wrapped <&0 >&1 2>/tmp/out.txt
EOF
  '';

  env.SYSTEMD_DBUS_INTERFACE_DIR = "${buildPackages.systemd}/share/dbus-1/interfaces";

  nativeCheckInputs = [
    clippy
  ];

  preCheck = ''
    echo "Running clippy..."
    cargo clippy -- -Dwarnings
  '';

  meta = {
    description = "NixOS switch-to-configuration program";
    mainProgram = "switch-to-configuration";
    maintainers = with lib.maintainers; [ jmbaur ];
    license = lib.licenses.mit;
  };
}
