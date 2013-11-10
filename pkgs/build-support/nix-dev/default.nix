{ stdenv, git, bash, writeText, coreutils, gnugrep, wget }:
let 
  mkscript = path : text : ''
    mkdir -pv $out/bin
    cat > ${path} <<"EOF"
    #!${bash}/bin/bash
    ME=`basename ${path}`
    _cdp() {
      cd $NIX_DEV_ROOT/nixpkgs || {
        echo "$ME: can't cd to NIX_DEV_ROOT" >&2
        exit 1
      }
    }
    _check_nixdev() {
      test -n "$NIX_DEV_ROOT" || {
        echo "$ME: NIX_DEV_ROOT is not set" >&2
        exit 1
      }
      test -d "$NIX_DEV_ROOT" || {
        echo "$ME: NIX_DEV_ROOT is not a directory" >&2
        exit 1
      }
    }
    ${text}
    EOF
    sed -i "s@%out@$out@g" ${path}
    chmod +x ${path}
  '';

  nix-dev-env = mkscript "$out/bin/nix-dev-env" ''
    _check_nixdev
    export NIX_PATH="nixpkgs=$NIX_DEV_ROOT/nixpkgs:nixos=$NIX_DEV_ROOT/nixpkgs/nixos:nixos-config=$NIX_DEV_ROOT/nixos-config:services=/etc/nixos/services"
    nix-env -f '<nixpkgs>' "$@"
  '';

  nix-dev-rebuild = mkscript "$out/bin/nix-dev-rebuild" ''
    _check_nixdev
    export NIX_PATH="nixpkgs=$NIX_DEV_ROOT/nixpkgs:nixos=$NIX_DEV_ROOT/nixpkgs/nixos:nixos-config=$NIX_DEV_ROOT/nixos-config:services=/etc/nixos/services"
    exec nixos-rebuild "$@"
  '';

  nix-dev-revision-latest = mkscript "$out/bin/nix-dev-revision-latest" ''
    rev=`${wget}/bin/wget -q  -S --output-document - http://nixos.org/releases/nixos/channels/nixos-unstable 2>&1 |
      ${gnugrep}/bin/grep Location | head -n 1 | sed -s 's/.*\.//'`
    if test -z "$rev" ; then
      echo "$ME: Error obtaining channel info from nixos.org" >&2
      exit 1
    fi
    echo $rev
  '';

  nix-dev-fetch = mkscript "$out/bin/nix-dev-fetch" ''
    _cdp
    ${git}/bin/git fetch origin
  '';

  nix-dev-rebase-check = mkscript "$out/bin/nix-dev-rebase-check" ''
    _cdp
    checkbr() {
      local BR=$1
      if ! ${git}/bin/git branch --all | ${gnugrep}/bin/grep -q -w "$BR" ; then
        echo "$ME: looks like your repo has not got branch named '$BR'. Aborting." >&2
        exit 1;
      fi
    }
    checkbr local
    checkbr remotes/origin/master
    out=`${git}/bin/git log --oneline  --no-merges local --not refs/remotes/origin/master local`
    if test -n "$out" ; then
      echo "$ME: failed: looks like there is a tricky case in the git repo. Please check it yourself" >&2
      exit 1;
    fi
  '';

  nix-dev-update = mkscript "$out/bin/nix-dev-update" ''
    _cdp

    (
    echo "$ME: Fetching origin" &&
    ${git}/bin/git fetch origin &&
    echo "$ME: Checking whether rebase is possible" &&
    %out/bin/nix-dev-rebase-check &&
    echo "$ME: Checking out local branch" &&
    ${git}/bin/git checkout local &&
    base=`${git}/bin/git merge-base local origin/master` &&
    echo "$ME: Backing up current branch to local-$base" &&
    ${git}/bin/git branch -f local-$base &&
    newref=`%out/bin/nix-dev-revision-latest` &&
    echo "$ME: Rebasing local to $newref" &&
    ${git}/bin/git rebase -f $newref &&
    true
    ) >&2

    if [ "$?" != "0" ] ; then
      echo "$ME: Automatic rebasing failed for nixpkgs. Do some git magic to fix it." >&2
      exit 1
    fi
  '';

in
stdenv.mkDerivation {
  name = "nix-dev-1.00";

  builder = writeText "builder.sh" ''
    . $stdenv/setup
    ${nix-dev-rebuild}
    ${nix-dev-env}
    ${nix-dev-revision-latest}
    ${nix-dev-fetch}
    ${nix-dev-rebase-check}
    ${nix-dev-update}
  '';

  meta = {
    description = "Nix-dev is a set of bash funtions";
    maintainers = with stdenv.lib.maintainers; [ smironov ];
    platforms = with stdenv.lib.platforms; linux;
  };
}

