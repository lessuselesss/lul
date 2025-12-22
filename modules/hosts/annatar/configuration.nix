{ inputs, ... }:
let
  flake.modules.nixos.annatar.imports = with inputs.self.modules.nixos; [
    lessuseless
    impermanence # User-level persistence (lessuseless module uses this)
    { wsl.defaultUser = "lessuseless"; }
  ];
in
{
  inherit flake;
}
