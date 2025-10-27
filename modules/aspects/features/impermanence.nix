{ inputs, ... }:
{
  flake-file.inputs = {
    impermanence.url = "github:nix-community/impermanence";
  };

  flake.aspects.impermanence = {
    nixos = {
      # NOTE: We only use home-manager impermanence (home.persistence),
      # not NixOS-level impermanence (environment.persistence).
      # The home-manager module is imported in lessuseless/impermanence.nix

      # Ensure /persist is mounted early in boot sequence
      fileSystems."/persist".neededForBoot = true;

      # Disable mutable users for impermanence setup
      users.mutableUsers = false;

      # Enable FUSE user_allow_other for home-manager impermanence mounts
      programs.fuse.userAllowOther = true;
    };
  };
}
