{ inputs, ... }:
{
  # Global defaults for all hosts and users
  flake.aspects = { aspects, ... }: {
    # Host defaults
    default.host.nixos = {
      system.stateVersion = "25.11";

      # Nix settings
      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;
      };
    };

    default.host.darwin = {
      system.stateVersion = 6;
    };

    # User defaults
    default.user.nixos = {
      # Users are mutable by default in non-impermanence setups
      # This will be overridden by impermanence aspect if used
    };

    # Home-manager defaults
    default.home.homeManager = { lib, ... }: {
      home.stateVersion = lib.mkDefault "25.05";
    };
  };
}
