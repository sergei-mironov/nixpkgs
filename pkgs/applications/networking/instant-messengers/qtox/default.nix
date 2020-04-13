{ stdenv, mkDerivation, lib, fetchFromGitHub, cmake, pkgconfig
, libtoxcore
, libpthreadstubs, libXdmcp, libXScrnSaver
, qtbase, qtsvg, qttools, qttranslations
, ffmpeg, filter-audio, libexif, libsodium, libopus
, libvpx, openal, pcre, qrencode, sqlcipher
, AVFoundation ? null }:

let
  version = "master";
  rev = "bd339d2cb64eb32528e081d916db275c2ec7454b";

in mkDerivation {
  pname = "qtox";
  inherit version;

  src = fetchFromGitHub {
    owner  = "qTox";
    repo   = "qTox";
    sha256 = "0qi47z5sawhwam40y061i0sqkvb41x2w66gbgysg585zg7x9h0as";
    inherit rev;
  };

  buildInputs = [
    libtoxcore
    libpthreadstubs libXdmcp libXScrnSaver
    qtbase qtsvg qttranslations
    ffmpeg filter-audio libexif libopus libsodium
    libvpx openal pcre qrencode sqlcipher
  ] ++ lib.optionals stdenv.isDarwin [ AVFoundation] ;

  nativeBuildInputs = [ cmake pkgconfig qttools ];

  enableParallelBuilding = true;

  cmakeFlags = [
    "-DGIT_DESCRIBE=${rev}"
    "-DENABLE_STATUSNOTIFIER=False"
    "-DENABLE_GTK_SYSTRAY=False"
    "-DENABLE_APPINDICATOR=False"
    "-DTIMESTAMP=1"
  ];

  meta = with lib; {
    description = "Qt Tox client";
    homepage    = https://tox.chat;
    license     = licenses.gpl3;
    maintainers = with maintainers; [ akaWolf peterhoeg ];
    platforms   = platforms.all;
  };
}
