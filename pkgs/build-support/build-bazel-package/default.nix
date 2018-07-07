{ stdenv, bazel }:

args@{ name, bazelFlags ? [], bazelTarget, buildAttrs, fetchAttrs, ... }:

let
  fArgs = removeAttrs args [ "buildAttrs" "fetchAttrs" ];
  fBuildAttrs = fArgs // buildAttrs;
  fFetchAttrs = fArgs // removeAttrs fetchAttrs [ "sha256" ];

in stdenv.mkDerivation (fBuildAttrs // rec {
  inherit name bazelFlags bazelTarget;

  deps = stdenv.mkDerivation (fFetchAttrs // {
    name = "${name}-deps";
    inherit bazelFlags bazelTarget;

    nativeBuildInputs = fFetchAttrs.nativeBuildInputs or [] ++ [ bazel ];

    dontAddPrefix = true;

    preHook = fFetchAttrs.preHook or "" + ''
      export bazelOut="$NIX_BUILD_TOP/output"
      export HOME="$NIX_BUILD_TOP"
    '';

    buildPhase = fFetchAttrs.buildPhase or ''
      runHook preBuild

      bazel --output_base="$bazelOut" fetch $bazelFlags $bazelTarget

      runHook postBuild
    '';

    installPhase = fFetchAttrs.installPhase or ''
      runHook preInstall

      # Patching markers to make them deterministic
      for i in $bazelOut/external/\@*.marker; do
        sed -i 's, -\?[0-9][0-9]*$, 1,' "$i"
      done
      # Patching symlinks to remove build directory reference
      find $bazelOut/external -type l | while read symlink; do
        ln -sf $(readlink "$symlink" | sed "s,$NIX_BUILD_TOP,NIX_BUILD_TOP,") "$symlink"
      done

      cp -r $bazelOut/external $out

      runHook postInstall
    '';

    dontFixup = true;
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = fetchAttrs.sha256;
  });

  dontAddPrefix = true;

  nativeBuildInputs = fBuildAttrs.nativeBuildInputs or [] ++ [ (bazel.override { enableNixHacks = false; }) ];

  preHook = fBuildAttrs.preHook or "" + ''
    export bazelOut="$NIX_BUILD_TOP/output"
    export HOME="$NIX_BUILD_TOP"
  '';

  preConfigure = ''
    mkdir -p $bazelOut/external
    cp -r $deps/* $bazelOut/external
    chmod -R +w $bazelOut
    find $bazelOut -type l | while read symlink; do
      ln -sf $(readlink "$symlink" | sed "s,NIX_BUILD_TOP,$NIX_BUILD_TOP,") "$symlink"
    done
  '' + fBuildAttrs.preConfigure or "";

  gccnh = stdenv.mkDerivation {
    name = "gccnh";
    buildCommand = ''
      . $stdenv/setup
      mkdir -p $out/bin

      for prog in as  c++  cc  cpp  g++  ld  ld.bfd  ld.gold ; do
        ln -s ${stdenv.cc}/bin/$prog $out/bin/$prog
      done

      cat >$out/bin/gcc <<"EOF"
      #!/bin/sh
      export hardeningDisable=all
      exec "${stdenv.cc}/bin/gcc" "''${extraFlagsArray[@]}" "$@"
      EOF
      chmod +x $out/bin/gcc
      '';
  };

  buildPhase = fBuildAttrs.buildPhase or ''
    runHook preBuild

    CC=${gccnh}/bin/gcc bazel --output_base="$bazelOut" build --verbose_failures  -j $NIX_BUILD_CORES $bazelFlags $bazelTarget

    runHook postBuild
  '';
})
