{ stdenv, lib, clang, buildGoPackage, fetchgit }:

buildGoPackage rec {
  name = "go-ethereum-${version}";
  version = "1.6.6";
  rev = "refs/tags/v${version}";
  goPackagePath = "github.com/ethereum/go-ethereum";

  buildInputs = [ clang ];

  src = fetchgit {
    inherit rev;
    url = "https://${goPackagePath}";
    sha256 = "066s7fp9pbyq670xwnib4p7zaxs941r9kpvj2hm6bkr28yrpvp1a";
  };

  preBuild = ''
    # need to use the same C compiler that was used to build go
    export CC="clang"
  '';

  meta = {
    homepage = "https://ethereum.github.io/go-ethereum/";
    description = "Official golang implementation of the Ethereum protocol";
    license = with lib.licenses; [ lgpl3 gpl3 ];
  };
}
