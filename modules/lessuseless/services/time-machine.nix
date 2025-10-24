{
  flake.modules.nixos.lessuseless =
    { config, pkgs, lib, ... }:
    let
      cfg = config.services.time-machine;
    in
    {
      options.services.time-machine = {
      enable = lib.mkEnableOption "httm-based time machine backups";

      # Scoped whitelist for btrfs native snapshots
      btrfsTargets = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            uuid = lib.mkOption {
              type = lib.types.str;
              description = "UUID of the btrfs filesystem to send snapshots to";
            };
            mountPoint = lib.mkOption {
              type = lib.types.str;
              description = "Where this filesystem should be mounted";
              example = "/mnt/backup-btrfs";
            };
            autoMount = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Auto-mount this filesystem";
            };
          };
        });
        default = [ ];
        description = "Btrfs filesystems allowed for native snapshot replication";
      };

      # Scoped whitelist for rsync backups
      rsyncTargets = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            uuid = lib.mkOption {
              type = lib.types.str;
              description = "UUID of the filesystem (any type)";
            };
            path = lib.mkOption {
              type = lib.types.str;
              description = "Path relative to mount point for backups";
              example = "backup/home-snapshots";
            };
            mountPoint = lib.mkOption {
              type = lib.types.str;
              description = "Where this filesystem should be mounted";
              example = "/mnt/backup-rsync";
            };
            autoMount = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Auto-mount this filesystem";
            };
          };
        });
        default = [ ];
        description = "Filesystems allowed for rsync-based snapshot backups";
      };

      snapshotSchedule = lib.mkOption {
        type = lib.types.str;
        default = "hourly";
        description = "Systemd timer schedule for local snapshots";
      };

      snapshotRetention = lib.mkOption {
        type = lib.types.str;
        default = "48h 7d 4w";
        description = "Snapshot retention policy (hourly daily weekly)";
      };

      subvolumes = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "home" ];
        description = "Btrfs subvolumes to snapshot";
      };
    };

    config = lib.mkIf cfg.enable {
      # Install httm and btrbk
      environment.systemPackages = with pkgs; [
        httm
        btrbk
      ];

      # Auto-mount btrfs backup targets
      fileSystems = lib.mkMerge (
        (map
          (target: {
            "${target.mountPoint}" = lib.mkIf target.autoMount {
              device = "/dev/disk/by-uuid/${target.uuid}";
              fsType = "btrfs";
              options = [ "noauto" "x-systemd.automount" "x-systemd.idle-timeout=300" ];
            };
          })
          cfg.btrfsTargets)
        ++
        (map
          (target: {
            "${target.mountPoint}" = lib.mkIf target.autoMount {
              device = "/dev/disk/by-uuid/${target.uuid}";
              options = [ "noauto" "x-systemd.automount" "x-systemd.idle-timeout=300" ];
            };
          })
          cfg.rsyncTargets)
      );

      # Local snapshot service using btrbk
      services.btrbk.instances.time-machine = {
        onCalendar = cfg.snapshotSchedule;
        settings = {
          timestamp_format = "long";
          snapshot_preserve = cfg.snapshotRetention;
          snapshot_preserve_min = "latest";
          snapshot_dir = ".snapshots";

          volume."/" = {
            subvolume = lib.mkMerge (
              map
                (subvol: {
                  "${subvol}" = {
                    snapshot_name = "${subvol}";

                    # Add btrfs send/receive targets
                    target = lib.mkMerge (
                      map
                        (target: "${target.mountPoint}/.snapshots/${subvol}")
                        cfg.btrfsTargets
                    );
                  };
                })
                cfg.subvolumes
            );
          };
        };
      };

      # Rsync backup services (one per target)
      systemd.services = lib.mkMerge (
        lib.imap0
          (idx: target:
            let
              backupPath = "${target.mountPoint}/${target.path}";
            in
            {
              "time-machine-rsync-${toString idx}" = {
                description = "Rsync snapshots to ${backupPath}";
                after = [ "btrbk-time-machine.service" ];
                wants = [ "${builtins.replaceStrings ["/"] ["-"] (lib.strings.removePrefix "/" target.mountPoint)}.mount" ];

                serviceConfig = {
                  Type = "oneshot";
                  User = "root";
                };

                script = ''
                  # Check if backup path is accessible
                  if [ ! -d "${backupPath}" ]; then
                    echo "Creating backup directory: ${backupPath}"
                    mkdir -p "${backupPath}"
                  fi

                  # Sync each subvolume's snapshots
                  ${lib.concatMapStringsSep "\n" (subvol: ''
                    if [ -d "/.snapshots/${subvol}" ]; then
                      echo "Backing up ${subvol} snapshots to ${backupPath}/${subvol}"
                      ${pkgs.rsync}/bin/rsync -av --delete \
                        --info=progress2 \
                        "/.snapshots/${subvol}/" \
                        "${backupPath}/${subvol}/"
                    fi
                  '') cfg.subvolumes}
                '';
              };
            })
          cfg.rsyncTargets
      );

      # Timer to run rsync backups after local snapshots
      systemd.timers = lib.mkMerge (
        lib.imap0
          (idx: target: {
            "time-machine-rsync-${toString idx}" = {
              description = "Rsync backup timer";
              wantedBy = [ "timers.target" ];
              timerConfig = {
                OnCalendar = cfg.snapshotSchedule;
                Persistent = true;
              };
            };
          })
          cfg.rsyncTargets
      );
    };
  };

  # Home-manager configuration for httm
  flake.modules.homeManager.lessuseless =
    { config, pkgs, lib, osConfig, ... }:
    {
      home.packages = lib.mkIf (osConfig.services.time-machine.enable or false) [ pkgs.httm ];

      programs.fish.shellAbbrs = lib.mkIf (osConfig.services.time-machine.enable or false) {
      ht = "httm";
      hts = "httm -s";
      htm = "httm -n"; # Show number of snapshots
      htr = "httm -r"; # Restore file from snapshot
    };
  };
}
