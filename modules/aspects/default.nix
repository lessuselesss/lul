{ inputs, ... }:
{
  # Global defaults for all hosts and users
  flake.aspects.default = {
    # Host defaults
    host = {
      nixos = {
        system.stateVersion = "25.11";

        # Nix settings
        nix.settings = {
          experimental-features = [ "nix-command" "flakes" ];
          auto-optimise-store = true;
        };
      };

      darwin = {
        system.stateVersion = 6;
      };
    };

    # User defaults
    user = {
      nixos = {
        # Users are mutable by default in non-impermanence setups
        # This will be overridden by impermanence aspect if used
      };
    };

    # Home-manager defaults
    home = {
      home.stateVersion = "25.05";
    };
  };
}
