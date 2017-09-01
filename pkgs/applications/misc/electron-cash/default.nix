{ stdenv, fetchurl, python2Packages }:

python2Packages.buildPythonApplication rec {
  name = "electron-${version}";
  version = "2.9.3";

  src = fetchurl {
    url = "https://electroncash.org/downloads/${version}/win-linux/Electron-Cash-${version}.tar.gz";
    sha256 = "0vdd2flid6irhv77igpfx1y39v6l27d9gz662wwpv0ysijzkyis0";
  };

  propagatedBuildInputs = with python2Packages; [
    dns
    ecdsa
    jsonrpclib
    pbkdf2
    protobuf3_0
    pyaes
    pycrypto
    pyqt4
    pysocks
    qrcode
    requests
    tlslite

    # plugins
    keepkey
    trezor

    # TODO plugins
    # amodem
    # btchip
    # matplotlib
  ];

  preBuild = ''
    sed -i 's,usr_share = .*,usr_share = "'$out'/share",g' setup.py
    pyrcc4 icons.qrc -o gui/qt/icons_rc.py
    # Recording the creation timestamps introduces indeterminism to the build
    sed -i '/Created: .*/d' gui/qt/icons_rc.py
  '';

  postInstall = ''
    # Despite setting usr_share above, these files are installed under
    # $out/nix ...
    mv $out/lib/python2.7/site-packages/nix/store"/"*/share $out
    rm -rf $out/lib/python2.7/site-packages/nix

    substituteInPlace $out/share/applications/electron.desktop \
      --replace "Exec=electrum %u" "Exec=$out/bin/electrum %u"
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/electrum help >/dev/null
  '';

  meta = with stdenv.lib; {
    description = "A lightweight Bitcoin wallet";
    longDescription = ''
      A Bitcoin-Cash client, forked from Electron wallet.
    '';
    homepage = http://www.electroncash.org/;
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
