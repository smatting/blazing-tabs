{}:

let
  pkgs = import (import ./nix/sources.nix).nixpkgs {};
  easy-ps = import (pkgs.fetchFromGitHub {
    owner = "justinwoo";
    repo = "easy-purescript-nix";
    rev = "13ace3addf14dd9e93af9132e4799b7badfbe99e";
    sha256 = "1gva113kyygjhn9i92vg6cyj15vhyfhq7haq51cvp4xdz4j0q4xn";
  }) {
    inherit pkgs;
  };

in pkgs.mkShell {
  buildInputs = [
    easy-ps.purs
    easy-ps.spago

    # pkgs.nodejs-10_x
  ];
}
