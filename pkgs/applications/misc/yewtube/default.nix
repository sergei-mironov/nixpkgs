{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "yewtube";
  version = "2.9.4.99999";

  src = fetchFromGitHub {
    owner = "mps-youtube";
    repo = "yewtube";
    # rev = "refs/tags/v${version}";
    rev = "a20be95";
    # hash = "sha256-5+0OaoUan9IFEqtMvpvtkfpd7IbFJhG52oROER5TY20=";
    # hash = "sha256-kj6ton9N+GhuPyG551GSqyH+amJoqZL+xAu9+PvItKM=";
    hash = "sha256-pxdlo0rVFAzMtmFoIFhO9lJ3huuiy/ZthCzl/AJa4I0=";
  };

  postPatch = ''
    # Don't try to detect the version at runtime with pip
    substituteInPlace mps_youtube/__init__.py \
      --replace "from pip._vendor import pkg_resources" "" \
      --replace "__version__ =" "__version__ = '${version}' #"
    # https://github.com/iamtalhaasghar/yewtube/pull/105
    sed -ie '/pyreadline/d' requirements.txt
  '';

  propagatedBuildInputs = with python3Packages; [
    pyperclip
    requests
    youtube-search-python
    yt-dlp
  ];

  checkInputs = with python3Packages; [
    pytestCheckHook
    dbus-python
    pygobject3
  ];

  preCheck = ''
    export XDG_CONFIG_HOME=$(mktemp -d)
  '';

  pythonImportsCheck = [ "mps_youtube" ];

  meta = with lib; {
    description = "Terminal based YouTube player and downloader, forked from mps-youtube";
    homepage = "https://github.com/iamtalhaasghar/yewtube";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ fgaz koral ];
  };
}
