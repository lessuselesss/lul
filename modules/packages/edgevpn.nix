{ inputs, ... }:
let
  flake-file.inputs.edgevpn = {
    url = "github:mudler/edgevpn";
    flake = false;
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.edgevpn = pkgs.buildGoModule {
        name = "edgevpn";
        src = inputs.edgevpn;
        doCheck = false;
        vendorHash = "sha256-qnSlLyfsKha/V4R7RBkbJ0gQk1tb83nu1WtIBA262Uw=";
        meta.mainProgram = "edgevpn";
      };
    };
in
{
  inherit flake-file perSystem;
}
