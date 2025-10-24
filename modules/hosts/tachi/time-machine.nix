# Time Machine backup configuration for tachi
{ ... }:
{
  flake.modules.nixos.tachi = {
    services.time-machine = {
      enable = true;

      # Take snapshots hourly
      snapshotSchedule = "hourly";

      # Keep: 48 hourly, 7 daily, 4 weekly snapshots
      snapshotRetention = "48h 7d 4w";

      # Snapshot the persist subvolume (contains user data via impermanence)
      subvolumes = [ "@persist" ];

      # Rsync backups to Ventoy drive (works with exfat)
      rsyncTargets = [
        {
          uuid = "F4D0-BA15"; # Ventoy drive
          path = "nixos-backups/tachi/persist-snapshots";
          mountPoint = "/run/media/lessuseless/Ventoy";
          autoMount = false; # Already auto-mounted by system
        }
      ];

      # If you add a btrfs-formatted backup drive later, add it here:
      # btrfsTargets = [
      #   {
      #     uuid = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
      #     mountPoint = "/mnt/backup-btrfs";
      #     autoMount = true;
      #   }
      # ];
    };
  };
}
