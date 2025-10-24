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
      # Temporary password: temp123 (change after rebuild with proper password)
      # Use initialHashedPassword with users.mutableUsers = false from impermanence
      initialHashedPassword = "$6$3pkmqC.4p8Dxi6VN$JM6bVQCBO2SjJE5/0JKJ0jwcS.GhwnVyvCRETtrNiee6Wj4ExSoyG4AUZKAWoNgRcY1ryR9lzTjKheAP7MKJ6/";
    };

    # Allow wheel group to use sudo without password
    # TODO: Set a proper password hash and remove this
    security.sudo.wheelNeedsPassword = false;
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
