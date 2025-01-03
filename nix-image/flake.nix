# https://jonascarpay.com/posts/2022-09-19-declarative-deployment.html#comparisons-with-other-methods
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs { inherit system; };

      # Derivations and other expressions go here

    in
    {
      packages.${system} = {
        inherit
          # Outputs go here
          ;
      };
    };
}