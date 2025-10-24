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

    # Disable systemd-machine-id-commit service
    # This service tries to commit transient machine-id to disk,
    # but preservation already handles /etc/machine-id persistence
    systemd.services.systemd-machine-id-commit.enable = false;
  };
}
