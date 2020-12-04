#! /usr/bin/env nix-shell
#! nix-shell -p nix-prefetch-git "python3.withPackages (ps: with ps; [ lxml ])"
#! nix-shell -i python

import json
import subprocess
import urllib.request

urllib.request.urlretrieve('https://raw.githubusercontent.com/shyiko/jabba/master/index.json', 'index.json')

jdks = {}

with open('hashes.json') as f:
    hashes = json.load(f)

with open('index.json') as f:
    index = json.load(f)
    for arch in index['linux']:
        for jdk in index['linux'][arch]:
            name = jdk.replace('jdk@', '')
            if name not in jdks:
                jdks[name] = {}
            for version in index['linux'][arch][jdk]:
                if version not in jdks[name]:
                    jdks[name][version] = {}
                jdks[name][version][arch] = index['linux'][arch][jdk][version]

def get_hash(url):
    if url not in hashes:
        result = subprocess.run(["nix-prefetch-url", url], stdout=subprocess.PIPE)
        hashes[url] = result.stdout.decode('utf-8').replace("\n", "");
        with open('hashes.json', 'w') as o:
            json.dump(hashes, o, indent=2)
            o.write("\n")
    return hashes[url]

# For now, include just these JDK's:
for name in [ "adopt", "adopt-openj9", "graalvm", "graalvm-ce-java8", "graalvm-ce-java11", "jdk", "openjdk", "openjdk-ri", "zulu" ]:
    with open(name + '.nix', 'w') as f:
        f.write("""{ stdenv
, fetchurl
, patchelf
, glibc
, xorg
, zlib
}:

# File generated by ./update.py, do not edit

{
""")
        for version in jdks[name]:
            # For now, only support the amd64 architecture
            if 'amd64' in jdks[name][version]:
                (compressor, url) = jdks[name][version]['amd64'].split('+', 1)
                filename = url.split('/')[-1]
                h = get_hash(url)
                f.write(f"""  "{version}" = (
    let result = stdenv.mkDerivation rec {{
    pname = "jdk-jabba-{name}";
    version = "{version}";
    src = fetchurl {{
      url = "{url}";
      sha256 = "{h}";
    }};
    buildPhase = "";
    installPhase = ''
      mkdir -p $out
      mv * $out
      for f in $out/bin/*; do
        ${{patchelf}}/bin/patchelf --set-interpreter ${{glibc}}/lib/ld-linux-x86-64.so.2 --set-rpath "$out/lib:$out/lib/jli:$out/lib/*/jli:${{zlib}}/lib:${{xorg.libXext}}/lib" $f || true
      done
      for f in $out/lib/*; do
        ${{patchelf}}/bin/patchelf --set-rpath $out/lib:${{zlib}}/lib:${{xorg.libXext}}/lib:${{xorg.libX11}}/lib:${{xorg.libXrender}}/lib:${{xorg.libXtst}}/lib:${{xorg.libXi}}/lib $f || true
      done
    '';
    passthru.home = result;
    passthru.jre = result;
    preferLocalBuild = true;
  }}; in result);
""")
        f.write("}\n")
