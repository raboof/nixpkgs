{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "go-protobuf";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "golang";
    repo = "protobuf";
    rev = "v${version}";
    sha256 = "sha256-TYx7nAyUE70hoCNKnR74FzWhrQyWG17VPoKH3vR+qOM=";
  };

  vendorSha256 = "sha256-CcJjFMslSUiZMM0LLMM3BR53YMxyWk8m7hxjMI9tduE=";

  doCheck = false;

  meta = with lib; {
    homepage        = "https://github.com/golang/protobuf";
    description     = "Go support for Protocol Buffers";
    longDescription = ''
      This module (`github.com/golang/protobuf`) contains Go bindings for protocol buffers.

      It has been superseded by the `google.golang.org/protobuf` module,
      which contains an updated and simplified API, support for protobuf reflection,
      and many other improvements.
      We recommend that new code use the `google.golang.org/protobuf` module.
    '';
    maintainers     = with maintainers; [ lewo ];
    license         = licenses.bsd3;
    platforms       = platforms.unix;
  };
}
