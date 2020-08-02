{ lib
, python3Packages
, fetchFromGitHub
, wrapQtAppsHook
, fetchpatch
}:

with python3Packages;

buildPythonApplication rec {
  pname = "inkcut";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "1c0mfdfy9iq4l683f3aa7cm7x2w9px83dyigc7655wvaq3bxi2rp";
  };

  # inkcut-from-inkscape needs 2.1.1 plus at least b92e1db6f1f8bc770e81c757981452888a5c404a
  # but also something to fix https://github.com/inkcut/inkcut/issues/247
  # and https://github.com/inkcut/inkcut/pull/260/commits/3bdef5b9e639bba4e2691f18fed9347ab576eeda
  patches = [
    # Inkscape 1.0 support for the plugin (already merged, expected in next post-2.1.1 release):
    # Even with this patch there are some warnings, but those should be harmless.
    (fetchpatch {
      url = "https://github.com/${pname}/${pname}/commit/b92e1db6f1f8bc770e81c757981452888a5c404a.patch";
      sha256 = "065s2labvh04j40kq2w41s16d8l9ppldcca8dv3v1af4svf232sr";
    })
  ];

  nativeBuildInputs = [ wrapQtAppsHook ];

  propagatedBuildInputs = [
    enamlx
    twisted
    lxml
    qreactor
    jsonpickle
    pyserial
    pycups
    qtconsole
    pyqt5
  ];

  # QtApplication.instance() does not work during tests?
  doCheck = false;

  postFixup = ''
    wrapQtApp $out/bin/inkcut --unset PYTHONPATH

    mkdir $out/inkscape-extension
    cp plugins/inkscape/* $out/inkscape-extension

    sed -i "s|cmd = \['inkcut'\]|cmd = \['$out/bin/inkcut'\]|" $out/inkscape-extension/inkcut_cut.py
    sed -i "s|cmd = \['inkcut'\]|cmd = \['$out/bin/inkcut'\]|" $out/inkscape-extension/inkcut_open.py
  '';


  meta = with lib; {
    homepage = "https://www.codelv.com/projects/inkcut/";
    description = "Control 2D plotters, cutters, engravers, and CNC machines";
    license = licenses.gpl3;
    maintainers = with maintainers; [ raboof ];
  };
}
