{ inputs, ... }:
{
  # Tachi host aspect - Intel 11th Gen i7-1165G7
  flake.aspects.tachi = {
    # Include feature aspects
    includes = { aspects, ... }: with aspects; [
      preservation
      impermanence
      disko
      niri-desktop
      kvm-intel
    ];

    # Host-specific configuration
    nixos =
      { pkgs, lib, config, ... }:
      {
        networking.hostName = "tachi";

        # Import host-specific preservation configuration
        imports = [ ../hosts/tachi/preservation.nix ];
      };
  };
}
