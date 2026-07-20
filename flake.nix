{
  description = "Cheatsheet for Nerd Font Symbols to use with a fuzzy finder like tv";

  outputs =
    {
      nix-gleam,
      nixpkgs,
      self,
      ...
    }:
    let
      inherit (nixpkgs) lib;

      forEachSystem = lib.genAttrs lib.systems.flakeExposed;
    in
    {
      packages = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          nerdfonts-cheatsheet = pkgs.callPackage ./. {
            inherit (nix-gleam.packages.${system}) buildGleamApplication;
          };
          default = self.packages.${system}.nerdfonts-cheatsheet;
        }
      );

      devShells = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          glyphs =
            pkgs.fetchFromGitHub {
              owner = "ryanoasis";
              repo = "nerd-fonts";
              rev = "v3.4.0";
              hash = "sha256-yr1v8gIUjNob1xcJB4r88CCRx/08Zbwg3PUCdQjUqik=";
            }
            + "/bin/scripts/lib";

        in
        {
          default = pkgs.mkShell {
            inputsFrom = [ self.packages.${system}.nerdfonts-cheatsheet ];
            packages = with pkgs; [ gleam ];

            shellHook = ''
              echo " linking glyphs..."

              ln -sfn ${glyphs} ./glyphs

              ./generate_csv.sh
            '';
          };
        }
      );
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-gleam = {
      url = "github:arnarg/nix-gleam";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
