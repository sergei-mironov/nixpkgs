{ stdenv
, lib
, fetchPypi
, buildPythonPackage
, pkgs_protobuf
, protobuf
, cmake
, pytestrunner
, numpy
, typing-extensions
, mypy
}:

buildPythonPackage rec {
  pname = "onnx";
  version = "1.2.2";

  buildInputs = [ mypy protobuf pkgs_protobuf cmake numpy pytestrunner typing-extensions ] ;
  src = fetchPypi {
    inherit pname version;
    sha256 = "1kyj0ivxdbi86mkq78wwm8hbgvl24xn5w8r1fvb5grd8md36xl4g";
  };

  # FIXME: Workaround 'ERROR: file not found: onnx/examples'. Maybe one shold
  # try `fetchgit` instead of `fetchPypi`.
  doCheck = false;

  meta = {
    homepage = https://onnx.ai;
    description = "Open Neural Network Exchange";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ smironov ];
  };
}
