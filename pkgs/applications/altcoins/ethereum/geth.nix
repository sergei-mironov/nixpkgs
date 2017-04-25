{ stdenv, fetchFromGitHub, go, gmp, leveldb }:

stdenv.mkDerivation rec {
  name = "geth-${version}";
  version = "1.3.3";
  buildInputs = [go gmp];

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "go-ethereum";
    rev = "facc47cb5cec97b22c815a0a6118816a98f39876";
    sha256 = "0zk3lrzb3lckj8ffk0mj4kmgrzviq70xnkhrzx01r1nxlk648g02";
  };

  installPhase = ''
    mkdir -p "$out"
    cp -r build/bin "$out/bin"
  '';

  meta = with stdenv.lib; {
    description = "Ethereum blockchain client";
    homepage = "https://ethereum.org/";
    maintainers = with maintainers; [ dvc ];
    license = licenses.gpl3;
  };
}
