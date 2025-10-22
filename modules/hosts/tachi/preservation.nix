{
  flake.modules.nixos.tachi = {
    # System-level preservation configuration
    preservation.preserveAt."/persist" = {
      directories = [
        {
          directory = "/var/lib/nixos";
          inInitrd = true; # Needed for system state
        }
        {
          directory = "/var/lib/systemd/coredump";
        }
        {
          directory = "/etc/nixos";
        }
        {
          directory = "/etc/NetworkManager/system-connections";
        }
      ];

      files = [
        {
          file = "/etc/machine-id";
          inInitrd = true; # Machine ID needed early in boot
        }
      ];
    };
  };
}
