# Configuration for tachi - Intel 11th Gen i7-1165G7
{ inputs, ... }:
{
  flake.modules.nixos.tachi.imports = with inputs.self.modules.nixos; [
    lessuseless
    preservation # System-level persistence (pure Nix)
    impermanence # User-level persistence (lessuseless module uses this)
    disko
    niri-desktop # Scrollable-tiling Wayland compositor
    kvm-intel
  ];
}
