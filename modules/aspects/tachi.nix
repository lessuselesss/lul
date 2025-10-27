{ inputs, ... }:
{
  # Tachi host aspect - Intel 11th Gen i7-1165G7
  flake.aspects.tachi = {
    # Include feature aspects using den pattern
    includes = { flake, ... }: with flake.aspects; [
      preservation
      impermanence
      disko
      niri-desktop
      kvm-intel
    ];

    nixos = { pkgs, lib, config, ... }: {
      networking.hostName = "tachi";

      # Set the platform for this host
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      # System-level preservation configuration for tachi
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
  };
}
