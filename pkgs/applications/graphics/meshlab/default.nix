{ mkDerivation, lib, fetchFromGitHub
, fetchpatch
, libGLU
, qtbase
, qtscript
, qtxmlpatterns
, lib3ds
, bzip2
, muparser
, eigen
, glew
, gmp
, levmar
, cmake
}:

mkDerivation rec {
  pname = "meshlab";
  version = "2020.07";

  src = fetchFromGitHub {
    owner = "cnr-isti-vclab";
    repo = "meshlab";
    rev = "Meshlab-2020.07";
    sha256 = "0vj849b57zk3k6lx35zzcjhr9gdy4hxqnnkb8chwy7hw262cm3ri";
    fetchSubmodules = true; # for vcglib
  };

  buildInputs = [
    libGLU
    qtbase
    qtscript
    qtxmlpatterns
    lib3ds
    bzip2
    muparser
    eigen
    glew
    gmp
    levmar
  ];

  nativeBuildInputs = [ cmake ];

  patches = [ ./no-build-date.patch ];

  preConfigure = ''
    substituteAll ${./meshlab.desktop} install/linux/resources/meshlab.desktop
    cd src
  '';

  cmakeFlags = [
    "-DALLOW_BUNDLED_EIGEN=OFF"
    "-DALLOW_BUNDLED_GLEW=OFF"
    "-DALLOW_BUNDLED_LIB3DS=OFF"
    "-DALLOW_BUNDLED_MUPARSER=OFF"
    "-DALLOW_BUNDLED_QHULL=OFF"
     # disable when available in nixpkgs
    "-DALLOW_BUNDLED_OPENCTM=ON"
    "-DALLOW_BUNDLED_SSYNTH=ON"
    # some plugins are disabled unless these are on
    "-DALLOW_BUNDLED_NEWUOA=ON"
    "-DALLOW_BUNDLED_LEVMAR=ON"
  ];

  enableParallelBuilding = true;

  meta = {
    description = "A system for processing and editing 3D triangular meshes.";
    homepage = http://www.meshlab.net/;
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [viric];
    platforms = with lib.platforms; linux;
  };
}
