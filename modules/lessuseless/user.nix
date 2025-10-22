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

  linux = {
    users.users.lessuseless = {
      isNormalUser = true;
      uid = 1000;  # Fixed UID for impermanence
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      # Allow autologin without password (change with `passwd` after first boot)
      hashedPassword = "";
    };
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
