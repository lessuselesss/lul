{ inputs, ... }:
{
  flake-file.inputs.nix-wallpaper.url = "github:lunik1/nix-wallpaper";
  flake-file.inputs.dms.url = "github:AvengeMedia/DankMaterialShell";

  flake.modules.homeManager.lessuseless =
    { pkgs, config, lib, ... }:
    {
      imports = [
        inputs.dms.homeModules.dankMaterialShell.default
        # DMS niri module disabled - conflicts with our custom config.kdl
        # inputs.dms.homeModules.dankMaterialShell.niri
      ];

      # Wallpaper package
      home.packages = [
        (inputs.nix-wallpaper.packages.${pkgs.system}.default.override {
          preset = "catppuccin-mocha-rainbow";
        })
      ];

      # Note: Niri config.kdl is linked by dots.nix (entire .config/niri directory)

      # GNOME Keyring for credential storage
      services.gnome-keyring = {
        enable = true;
        components = [ "pkcs11" "secrets" "ssh" ];
      };

      # DankMaterialShell - replaces waybar and mako
      programs.dankMaterialShell = {
        enable = true;
        enableSystemd = true;

        # Feature flags
        enableSystemMonitoring = true;
        enableClipboard = true;
        enableVPN = true;
        enableBrightnessControl = true;
        enableColorPicker = true;
        enableDynamicTheming = true;
        enableAudioWavelength = true;
        enableCalendarEvents = false;  # Requires khal setup
        enableSystemSound = true;

        # Niri integration disabled - we're using custom config.kdl
        # You can manually add DMS keybinds to your niri config.kdl if desired
        niri = {
          enableKeybinds = false;
          enableSpawn = true;  # Still auto-start DMS
        };
      };

      # Swayidle for automatic screen locking
      # Note: DMS has its own lock screen (Super+Alt+L)
      services.swayidle = {
        enable = true;
        timeouts = [
          {
            timeout = 300;
            command = "dms ipc lock lock";
          }
          {
            timeout = 600;
            command = "${pkgs.systemd}/bin/systemctl suspend";
          }
        ];
      };
    };
}
