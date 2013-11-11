{ stdenv, language, firefoxWrapper, firefoxPkgs, gnused, bash, wget }:
let

  version = firefoxPkgs.xulVersion;

  mkscript = name : text : ''
    mkdir -pv $out/bin
    cat > $out/bin/${name} <<"EOF"
    #!${bash}/bin/bash
    ${text}
    EOF
    chmod +x $out/bin/${name}
  '';

  # FIXME: encode more archs. Check
  # ftp://ftp.mozilla.org/pub/mozilla.org/firefox/releases/${version} for naming
  # pattern.
  arch = assert stdenv.isLinux;
    if stdenv.is64bit
      then "linux-x86_64"
      else "linux-i686";

  langurl = "ftp://ftp.mozilla.org/pub/mozilla.org/firefox/releases/${version}/${arch}/xpi/${language}.xpi";

  wrapper = mkscript "firefox" ''
    LANGPACK=~/.firefox-${version}-langpack-${language}.xpi
    if ! test -f "$LANGPACK" ; then
      (
        # Downloads language pack in separate process
        ${wget}/bin/wget ${langurl} -O "$LANGPACK" &&
        ${firefoxWrapper}/bin/firefox -UILocale ${language} "$LANGPACK"
      ) &
    fi
    exec ${firefoxWrapper}/bin/firefox -UILocale ${language} "''${extraFlagsArray[@]}" "$@"
  '';
in
stdenv.mkDerivation {

  name = firefoxWrapper.name + "-with-localeWrapper";

  buildCommand = ''
    mkdir -pv $out/bin
    ${wrapper}

    mkdir -pv $out/share/applications
    cp ${firefoxWrapper}/share/applications/* $out/share/applications

    mkdir -pv $out/nix-support
    echo ${firefoxWrapper} > $out/nix-support/propagated-user-env-packages
  '';

  meta = {
    description =
      firefoxWrapper.meta.description
      + " (with ${language} locale wrapper) ";
  };
}

