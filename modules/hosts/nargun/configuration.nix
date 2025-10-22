{ inputs, ... }:
let
  flake.modules.nixos.nargun.imports = with inputs.self.modules.nixos; [
    lessuseless
    impermanence  # User-level persistence (lessuseless module uses this)
    niri-desktop
    xfce-desktop
    macos-keys
    kvm-amd
  ];

in
{
  inherit flake;
}
