{ inputs, ... }:
{
  flake-file.inputs = {
    preservation.url = "github:nix-community/preservation";
  };

  flake.modules.nixos.preservation = {
    imports = [
      inputs.preservation.nixosModules.default
    ];

    preservation.enable = true;

    # Preservation requires systemd-based initrd (not scripted)
    boot.initrd.systemd.enable = true;
  };
}
