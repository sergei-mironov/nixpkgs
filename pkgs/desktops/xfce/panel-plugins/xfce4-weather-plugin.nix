{ stdenv, fetchurl, pkgconfig, intltool, gtk3, libxml2, libsoup, upower,
libxfce4ui, libxfce4util, xfce4-panel, hicolor-icon-theme, xfconf }:

stdenv.mkDerivation rec {
  name = "${p_name}-${ver_maj}.${ver_min}";
  p_name  = "xfce4-weather-plugin";
  ver_maj = "0.11";
  ver_min = "0";

  src = fetchurl {
    url = "mirror://xfce/src/panel-plugins/${p_name}/${ver_maj}/${name}.tar.bz2";
    sha256 = "sha256:1z2k24d599mxf5gqa35i3xmc3gk2yvqs80hxxpyw06yma6ljw973";
  };

  nativeBuildInputs = [ pkgconfig intltool ];

  buildInputs = [ gtk3 libxml2 libsoup upower libxfce4ui libxfce4util
   xfce4-panel hicolor-icon-theme xfconf ];

  enableParallelBuilding = true;

  meta = {
    homepage = "http://goodies.xfce.org/projects/panel-plugins/${p_name}";
    description = "Weather plugin for the Xfce desktop environment";
    license = stdenv.lib.licenses.gpl2Plus;
    platforms = stdenv.lib.platforms.unix;
    maintainers = [ stdenv.lib.maintainers.romildo ];
  };
}
