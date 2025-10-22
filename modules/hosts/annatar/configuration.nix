{ inputs, ... }:
let
  flake.modules.nixos.annatar.imports = with inputs.self.modules.nixos; [
    lessuseless
    { wsl.defaultUser = "lessuseless"; }
  ];
in
{
  inherit flake;
}
