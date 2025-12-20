{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];
  flake-file.inputs.treefmt-nix.url = "github:numtide/treefmt-nix";

  perSystem.treefmt.projectRootFile = "flake.nix";
  perSystem.treefmt.programs = {
    nixfmt.enable = true;
    nixfmt.excludes = [ ".direnv" ];
    deadnix.enable = true;
    fish_indent.enable = true;
    kdlfmt.enable = true;
  };
}
