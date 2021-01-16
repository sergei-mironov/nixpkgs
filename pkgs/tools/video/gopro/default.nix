{ lib, stdenv, fetchFromGitHub
, ffmpeg
, imagemagick
, makeWrapper
, mplayer
}:

stdenv.mkDerivation rec {
  pname = "gopro";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "KonradIT";
    repo = "gopro-linux";
    rev = "9eecde65967bcbf4246a8489beb84c5ee3da4879";
    sha256 = "sha256:1c42nkxjwyzl00w4sj9pzvccsn7w7vn4ixmirdbq5nzqhyhv3pcc";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -Dm755 gopro -t $out/bin
    wrapProgram $out/bin/gopro \
      --prefix PATH ":" "${lib.makeBinPath [ ffmpeg imagemagick mplayer ]}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Command line interface for processing media filmed on GoPro HERO 3, 4, 5, 6, and 7 cameras";
    homepage = "https://github.com/KonradIT/gopro-linux";
    platforms = platforms.unix;
    license = licenses.gpl3;
    maintainers = with maintainers; [ jonringer ];
  };
}
