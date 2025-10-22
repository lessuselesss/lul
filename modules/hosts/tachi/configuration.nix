# Configuration for tachi - Intel 11th Gen i7-1165G7
{ inputs, ... }:
{
  flake.modules.nixos.tachi.imports = with inputs.self.modules.nixos; [
    lessuseless
    impermanence
    disko
    xfce-desktop
    macos-keys
    kvm-intel
  ];
}
