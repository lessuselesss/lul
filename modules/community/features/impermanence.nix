{ inputs, ... }:
{
  flake-file.inputs = {
    impermanence.url = "github:nix-community/impermanence";
  };

  flake.modules.nixos.impermanence = {
    # NOTE: We only use home-manager impermanence (home.persistence),
    # not NixOS-level impermanence (environment.persistence).
    # The home-manager module is imported in user-specific configs.

    # Ensure /persist is mounted early in boot sequence
    fileSystems."/persist".neededForBoot = true;

    # Disable mutable users for impermanence setup
    users.mutableUsers = false;

    # Enable FUSE user_allow_other for home-manager impermanence mounts
    programs.fuse.userAllowOther = true;
  };
}
