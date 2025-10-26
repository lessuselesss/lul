{ inputs, ... }:
{
  # Lessuseless user aspect
  flake.aspects.lessuseless = {
    # System-level user configuration via provider
    provides.default =
      { host, user }:
      class:
      { pkgs, lib, config, ... }:
      {
        # Common configuration across all platforms
        home-manager.backupFileExtension = "backup";
        programs.fish.enable = true;

        fonts.packages = with pkgs.nerd-fonts; [
          victor-mono
          jetbrains-mono
          inconsolata
        ];

        users.users.lessuseless = {
          description = "lessuseless";
          shell = pkgs.fish;
        };
      };

    # NixOS-specific configuration
    nixos =
      { pkgs, lib, config, ... }:
      {
        users.users.lessuseless = {
          isNormalUser = true;
          uid = 1000; # Fixed UID for impermanence
          extraGroups = [
            "networkmanager"
            "wheel"
            "video" # Access to video devices
            "audio" # Access to audio devices
            "plugdev" # Access to pluggable devices (USB, etc.)
          ];
          # Password configured via initialHashedPassword
          # Use initialHashedPassword with users.mutableUsers = false from impermanence
          initialHashedPassword = "$6$.K.oyv.fU6Gqu1ov$aia2TQleZO1L7VhUS6XoBAf08ZXx7ATE42B6/l0G5YGrwbUT0eOZDTuSHAmAHW3L50mBVcyh3m3Fk7ndq9Jby/";
        };

        # Require password for sudo
        security.sudo.wheelNeedsPassword = true;

        # Auto-login when display manager is enabled
        services.displayManager = lib.mkIf config.services.displayManager.enable {
          autoLogin = {
            enable = true;
            user = "lessuseless";
          };
        };
      };

    # Darwin-specific configuration
    darwin = {
      system.primaryUser = "lessuseless";
    };

    # Home-manager configuration
    # This pulls in all the existing lessuseless home-manager modules
    homeManager = {
      imports = [ inputs.self.modules.homeManager.lessuseless ];
    };
  };
}
