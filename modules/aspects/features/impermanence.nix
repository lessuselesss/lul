{ inputs, ... }:
{
  flake-file.inputs = {
    impermanence.url = "github:nix-community/impermanence";
  };

  flake.aspects.impermanence = {
    nixos = {
      imports = [ inputs.impermanence.nixosModules.impermanence ];

      # Ensure /persist is mounted early in boot sequence
      fileSystems."/persist".neededForBoot = true;

      # Disable mutable users for impermanence setup
      users.mutableUsers = false;

      # Enable FUSE user_allow_other for home-manager impermanence mounts
      programs.fuse.userAllowOther = true;
    };
  };
}
