{ inputs, ... }:
{
  imports = [
    inputs.devshell.flakeModule
    inputs.home-manager.flakeModules.home-manager
    inputs.treefmt-nix.flakeModule
  ];

  flake-file.inputs = {
    devshell.url = "github:numtide/devshell";
    home-manager.url = "github:nix-community/home-manager";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
}
