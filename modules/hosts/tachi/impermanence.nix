{
  flake.modules.nixos.tachi = {
    # System-level impermanence configuration
    environment.persistence."/persist" = {
      hideMounts = true;

      directories = [
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/etc/nixos"
        "/etc/NetworkManager/system-connections"
      ];

      files = [
        "/etc/machine-id"
      ];
    };
  };
}
