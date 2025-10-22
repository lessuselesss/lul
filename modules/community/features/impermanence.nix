{ inputs, ... }:
{
  flake-file.inputs = {
    impermanence.url = "github:nix-community/impermanence";
  };

  flake.modules.nixos.impermanence = {
    imports = [
      inputs.impermanence.nixosModules.impermanence
    ];

    # Ensure /persist is mounted early in boot sequence
    fileSystems."/persist".neededForBoot = true;

    # Disable mutable users for impermanence setup
    users.mutableUsers = false;
  };
}
