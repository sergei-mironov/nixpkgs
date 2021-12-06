{ lib, stdenv, fetchFromGitHub
, pkg-config, cmake, ninja, yasm
, libjpeg, openssl, libopus, ffmpeg, alsa-lib, libpulseaudio, protobuf
# HEAD
# , xorg, libXtst, libXcomposite, libXdamage, libXext, libXrender, libXrandr
# , glib, abseil-cpp, pcre, util-linuxMinimal, libselinux, libsepol, pipewire
# , libXi
# =======
, xorg, openh264, usrsctp, libevent, libvpx
, libX11, libXtst, libXcomposite, libXdamage, libXext, libXrender, libXrandr, libXi
, glib, abseil-cpp, pcre, util-linuxMinimal, libselinux, libsepol, pipewire
# f6c5598f54e (tdesktop: Cleanup/refactor)
}:

stdenv.mkDerivation {
  pname = "tg_owt";
  version = "unstable-2021-10-21";

  src = fetchFromGitHub {
    owner = "desktop-app";
    repo = "tg_owt";
    rev = "d578c760dc6f1ae5f0f3bb5317b0b2ed04b79138";
    sha256 = "12lr50nma3j9df55sxi6p48yhn9yxrwzz5yrx7r29p8p4fv1c75w";
    fetchSubmodules = true;
  };

  outputs = [ "out" "dev" ];

  nativeBuildInputs = [ pkg-config cmake ninja yasm ];

  buildInputs = [
    libjpeg openssl libopus ffmpeg alsa-lib libpulseaudio protobuf
    xorg.libX11 libXtst libXcomposite libXdamage libXext libXrender libXrandr
    glib abseil-cpp pcre util-linuxMinimal libselinux libsepol pipewire
    libXi
  ];

  cmakeFlags = [
    # Building as a shared library isn't officially supported and currently broken:
    "-DBUILD_SHARED_LIBS=OFF"
  ];

  meta.license = lib.licenses.bsd3;
}
