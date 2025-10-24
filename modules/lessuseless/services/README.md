# Services

This directory contains service modules for system-level services.

## Available Services

### time-machine.nix

httm-based backup solution with btrfs snapshots and rsync capabilities.

**Features:**
- Automatic btrfs snapshots using btrbk
- Scoped whitelist for backup targets (UUID-based)
- Native btrfs send/receive for btrfs targets
- Rsync fallback for any filesystem (exfat, ntfs, ext4)
- Browse and restore files with httm

**Usage in host configuration:**
```nix
services.time-machine = {
  enable = true;
  snapshotSchedule = "hourly";
  snapshotRetention = "48h 7d 4w";
  subvolumes = [ "@persist" ];

  # Rsync to any filesystem
  rsyncTargets = [{
    uuid = "F4D0-BA15";
    path = "nixos-backups/hostname/persist-snapshots";
    mountPoint = "/run/media/lessuseless/Ventoy";
    autoMount = false;
  }];

  # Native btrfs snapshots (optional)
  btrfsTargets = [{
    uuid = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
    mountPoint = "/mnt/backup-btrfs";
    autoMount = true;
  }];
};
```

**Fish shell abbreviations:**
- `ht <file>` - Browse file history
- `hts` - List snapshots
- `htm <file>` - Show snapshot count
- `htr <file>` - Restore from snapshot

## Adding New Services

Create a new `.nix` file in this directory following the dendritic pattern:

```nix
{ config, pkgs, lib, ... }:
{
  flake.modules.nixos.lessuseless = {
    # NixOS system configuration
    options.services.my-service = { ... };
    config = lib.mkIf config.services.my-service.enable { ... };
  };

  flake.modules.homeManager.lessuseless = {
    # Home-manager user configuration (optional)
  };
}
```

Services are auto-discovered by import-tree - no manual imports needed!
