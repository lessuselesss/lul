{ inputs, ... }:
let
  flake.modules.nixos.lessuseless.imports = [
    user
    linux
    autologin
    home
  ];

  flake.modules.darwin.lessuseless.imports = [
    user
    darwin
    home
  ];

  home.home-manager.users.lessuseless.imports = [
    inputs.self.homeModules.lessuseless
  ];

  autologin =
    { config, lib, ... }:
    lib.mkIf config.services.displayManager.enable {
      services.displayManager.autoLogin.enable = true;
      services.displayManager.autoLogin.user = "lessuseless";
    };

  linux =
    { lib, ... }:
    {
      users.users.lessuseless = {
        isNormalUser = true;
        uid = 1000;  # Fixed UID for impermanence
        extraGroups = [
          "networkmanager"
          "wheel"
          "video"      # Access to video devices
          "audio"      # Access to audio devices
          "plugdev"    # Access to pluggable devices (USB, etc.)
        ];
        # Password configured via initialHashedPassword
        # Use initialHashedPassword with users.mutableUsers = false from impermanence
        initialHashedPassword = "$6$.K.oyv.fU6Gqu1ov$aia2TQleZO1L7VhUS6XoBAf08ZXx7ATE42B6/l0G5YGrwbUT0eOZDTuSHAmAHW3L50mBVcyh3m3Fk7ndq9Jby/";
      };

      # Require password for sudo
      security.sudo.wheelNeedsPassword = true;

      # Increase timeout for home-manager activation (Doom Emacs can take a while)
      systemd.services."home-manager-lessuseless".serviceConfig.TimeoutStartSec = lib.mkForce "10min";
    };

  darwin.system.primaryUser = "lessuseless";

  user =
    { pkgs, ... }:
    {
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
in
{
  inherit flake;
}
