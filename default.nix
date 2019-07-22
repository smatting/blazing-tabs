# (import ./default.nix { pkgs = import (import ./nix/sources.nix).nixpkgs {}; })
let
  pkgs = import (import ./nix/sources.nix).nixpkgs {};
in
  with pkgs.nodePackages;
  {
    elm = pkgs.elmPackages.elm;
    elm-live = pkgs.nodePackages.elm-live;
  }
