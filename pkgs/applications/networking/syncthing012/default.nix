{ stdenv, fetchgit, go }:

stdenv.mkDerivation rec {
  version = "0.12.15";
  name = "syncthing-${version}";

  src = fetchgit {
    url = https://github.com/syncthing/syncthing;
    rev = "refs/tags/v${version}";
    sha256 = "0g4sj509h45iq6g7b0pl88rbbn7c7s01774yjc6bl376x1xrl6a1";
  };

  # Upstream:  goDeps = ./deps.nix;
  buildInputs = [ go ];

  buildPhase = ''
    mkdir -p src/github.com/syncthing
    ln -s $(pwd) src/github.com/syncthing/syncthing
    export GOPATH=$(pwd)

    # Syncthing's build.go script expects this working directory
    cd src/github.com/syncthing/syncthing

    go run build.go -no-upgrade -version v${version} install
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp bin/* $out/bin
  '';

  meta = {
    homepage = https://www.syncthing.net/;
    description = "Open Source Continuous File Synchronization";
    license = stdenv.lib.licenses.mpl20;
    maintainers = with stdenv.lib.maintainers; [pshendry];
    platforms = with stdenv.lib.platforms; linux ++ freebsd ++ openbsd ++ netbsd;
  };
}
