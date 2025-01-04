# https://github.com/stackbuilders/nixpkgs-terraform?tab=readme-ov-file#install
# https://jonascarpay.com/posts/2022-09-19-declarative-deployment.html
{
  inputs = {
    nixpkgs-terraform.url = "github:stackbuilders/nixpkgs-terraform";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
  };

  #nixConfig = {
  #  extra-substituters = "https://nixpkgs-terraform.cachix.org";
  #  extra-trusted-public-keys = "nixpkgs-terraform.cachix.org-1:8Sit092rIdAVENA3ZVeH9hzSiqI/jng6JiCrQ1Dmusw=";
  #};

  outputs = inputs:
    let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs { inherit system; config.allowUnfree = true; };

      iplz-lib = pkgs.python3Packages.buildPythonPackage {
        name = "iplz";
        src = ./app;
        propagatedBuildInputs = [ pkgs.python313Packages.falcon ];
      };

      iplz-server = pkgs.writeShellApplication {
        name = "iplz-server";
        runtimeInputs = [ (pkgs.python313.withPackages (p: [ p.uvicorn p.falcon iplz-lib ])) ];
        text = ''
          uvicorn app.iplz:app "$@"
        '';
      };

      deploy-shell = pkgs.mkShell {
        packages = [
          pkgs.terraform
          pkgs.awscli2
        ];
        allowUnfree = true;
      };

    in
    {
      devShell.${system} = deploy-shell;
      # install app here
      packages.${system} = {
        inherit
          iplz-lib
          iplz-server;
      };
    };
}
