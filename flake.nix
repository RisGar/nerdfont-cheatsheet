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
          inherit (nix-gleam.packages.${system}) buildGleamApplication;
        in
        {
          nerdfonts-cheatsheet = buildGleamApplication {
            src = lib.cleanSource ./.;
            erlangPackage = pkgs.beamMinimal29Packages.erlang;
          };
          default = self.packages.${system}.nerdfonts-cheatsheet;
        }
      );

      devShells = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            inputsFrom = [ self.packages.${system}.nerdfonts-cheatsheet ];
            packages = with pkgs; [ gleam ];
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
