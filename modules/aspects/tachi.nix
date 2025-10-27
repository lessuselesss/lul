{ inputs, ... }:
{
  # Tachi host aspect - Intel 11th Gen i7-1165G7
  flake.aspects.tachi.nixos =
    { pkgs, lib, config, ... }:
    {
      networking.hostName = "tachi";

      # Import feature modules
      imports = [
        inputs.self.modules.nixos.preservation
        inputs.self.modules.nixos.impermanence
        inputs.self.modules.nixos.disko
        inputs.self.modules.nixos.niri-desktop
        inputs.self.modules.nixos.kvm-intel
      ];

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
}
