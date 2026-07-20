{
  buildGleamApplication,
  lib,
  beamMinimal29Packages,
  fetchFromGitHub,
  ...
}:
let
  glyphs =
    fetchFromGitHub {
      owner = "ryanoasis";
      repo = "nerd-fonts";
      rev = "v3.4.0";
      hash = "sha256-yr1v8gIUjNob1xcJB4r88CCRx/08Zbwg3PUCdQjUqik=";
    }
    + "/bin/scripts/lib";
in
buildGleamApplication {
  src = lib.cleanSource ./.;
  erlangPackage = beamMinimal29Packages.erlang;

  preConfigure = ''
    echo " linking glyphs..."

    ln -sfn ${glyphs} ./glyphs

    ./generate_csv.sh
  '';
}
