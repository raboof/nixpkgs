{ stdenv, fetchFromGitHub, python3Packages, glibcLocales, fetchpatch }:

with python3Packages;

buildPythonPackage rec {
  pname = "mitmproxy";
  version = "5.2";

  src = fetchFromGitHub {
    owner  = pname;
    repo   = pname;
    rev    = "v${version}";
    sha256 = "0ja0aqnfmkvns5qmd51hmrvbw8dnccaks30gxgzgcjgy30rj4brq";
  };

  postPatch = ''
    # remove dependency constraints
    sed 's/>=\([0-9]\.\?\)\+\( \?, \?<\([0-9]\.\?\)\+\)\?\( \?, \?\!=\([0-9]\.\?\)\+\)\?//' -i setup.py
  '';

  patches = [
    # This test doesn't work for us since we don't want to fetch the .git
    ./0000-dont-test-git-version.patch
    # nixpkgs ships urwid 2.1.1, to this can/should be applied.
    # will be part of the next post-5.2 version:
    (fetchpatch {
      url = "https://github.com/${pname}/${pname}/commit/ea9177217208fdf642ffc54f6b1f6507a199350c.patch";
      sha256 = "1z5r8izg5nvay01ywl3xc6in1vjfi9f144j057p3k5rzfliv49gg";
    })
  ];

  doCheck = (!stdenv.isDarwin);

  # examples.complex.xss_scanner doesn't import correctly with pytest5
  checkPhase = ''
    export HOME=$(mktemp -d)
    export LC_CTYPE=en_US.UTF-8
    pytest --ignore test/examples \
      -k 'not test_find_unclaimed_URLs and not test_tcp'
  '';

  propagatedBuildInputs = [
    blinker brotli certifi cffi
    click cryptography flask h11
    h2 hpack hyperframe itsdangerous
    jinja2 kaitaistruct ldap3 markupsafe
    passlib protobuf publicsuffix2 pyasn1
    pycparser pyopenssl pyparsing pyperclip
    ruamel_yaml setuptools six sortedcontainers
    tornado urwid werkzeug wsproto zstandard
  ];

  checkInputs = [
    beautifulsoup4 flask pytest
    requests glibcLocales
    asynctest parver pytest-asyncio
    hypothesis
  ];

  meta = with stdenv.lib; {
    description = "Man-in-the-middle proxy";
    homepage    = "https://mitmproxy.org/";
    license     = licenses.mit;
    maintainers = with maintainers; [ fpletz kamilchm ];
  };
}
