{ stdenv
, fetchFromGitHub
, pkgconfig
, which
, cmake
, mkDerivation

, qtmultimedia
, wrapQtAppsHook

, frei0r
, opencolorio
, openimageio
, openexr
, ffmpeg-full

, CoreFoundation }:

mkDerivation rec {
  pname = "olive-editor";
  version = "snapshot-2020-08-30";

  src = fetchFromGitHub {
    owner = "olive-editor";
    repo = "olive";
    rev = "e42ba3f9d4042eb062e0575ac3af8b187f1e064c";
    sha256 = "16swl8651sbg3l0310h0j5408qrnzjiq7asgmwrjsmh5j2pidz1j";
  };

  nativeBuildInputs = [
    pkgconfig
    which
    wrapQtAppsHook
    cmake
  ];

  buildInputs = [
    ffmpeg-full
    frei0r
    opencolorio
    openimageio
    openexr
    qtmultimedia
  ] ++ stdenv.lib.optional stdenv.isDarwin CoreFoundation;

  meta = with stdenv.lib; {
    description = "Professional open-source NLE video editor";
    homepage = "https://www.olivevideoeditor.org/";
    downloadPage = "https://www.olivevideoeditor.org/download.php";
    license = licenses.gpl3;
    maintainers = [ maintainers.balsoft ];
    platforms = platforms.unix;
  };
}
