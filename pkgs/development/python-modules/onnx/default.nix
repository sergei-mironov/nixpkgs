{ stdenv
, lib
, fetchPypi
, buildPythonPackage
, protobuf
, cmake
, mypy
, numpy
, typing-extensions
}:

buildPythonPackage rec {
  pname = "onnx";
  version = "1.2.2";

  propagatedBuildInputs = [ protobuf ];

  buildInputs = [ cmake numpy mypy typing-extensions ] ;
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
