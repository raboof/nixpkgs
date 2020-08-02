{ lib
, inkscape
, runCommand
, makeWrapper
, inkscapeExtensions ? []
}:

runCommand "inkscape-with-extensions-${lib.getVersion inkscape}" {
  buildInputs = [ inkscape makeWrapper ];
  dontPatchELF = true;
  dontStrip = true;
  meta = inkscape.meta;
} ''
  mkdir -p "$out/bin"
  mkdir "$out/share"

  for d in $(ls ${inkscape}/share); do
    if [ $d != "inkscape" ]; then
      ln -s "${inkscape}/share/$d" "$out/share/$d"
    fi
  done

  mkdir $out/share/inkscape
  for d in $(ls ${inkscape}/share/inkscape); do
    if [ $d != "extensions" ]; then
      ln -s "${inkscape}/share/inkscape/$d" "$out/share/inkscape/$d"
    fi
  done

  mkdir $out/share/inkscape/extensions
  for d in $(ls ${inkscape}/share/inkscape/extensions); do
    ln -s "${inkscape}/share/inkscape/extensions/$d" "$out/share/inkscape/extensions/$d"
  done

  for e in ${lib.concatStringsSep " " inkscapeExtensions}; do
    for f in $(ls $e); do
      ln -s $e/$f $out/share/inkscape/extensions/$f || echo "Skipping duplicate extension path: $f from $e"
    done
  done

  makeWrapper "${inkscape}/bin/inkscape" "$out/bin/inkscape" --set INKSCAPE_DATADIR "$out/share" --set PYTHONPATH "${lib.concatStringsSep "," inkscapeExtensions}"
''
