{ inputs, ... }:
{
  flake-file.inputs.nix-wallpaper.url = "github:lunik1/nix-wallpaper";

  flake.modules.homeManager.lessuseless =
    { pkgs, config, lib, ... }:
    {
      # Wallpaper package
      home.packages = [
        (inputs.nix-wallpaper.packages.${pkgs.system}.default.override {
          preset = "catppuccin-mocha-rainbow";
        })
      ];
      # Niri configuration file (KDL format)
      home.file.".config/niri/config.kdl".source = ./dots/config/niri/config.kdl;

      # GNOME Keyring for credential storage
      services.gnome-keyring = {
        enable = true;
        components = [ "pkcs11" "secrets" "ssh" ];
      };

      # Waybar configuration for niri
      programs.waybar = {
        enable = true;
        settings = [{
          layer = "top";
          position = "top";
          height = 30;

          modules-left = [ "niri/workspaces" "niri/window" ];
          modules-center = [ "clock" ];
          modules-right = [ "pulseaudio" "network" "battery" "tray" ];

          "niri/workspaces" = {
            format = "{icon}";
            format-icons = {
              active = "";
              default = "";
            };
          };

          "niri/window" = {
            max-length = 50;
          };

          clock = {
            format = "{:%H:%M %a %d %b}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = " muted";
            format-icons = {
              default = [ "" "" "" ];
            };
            on-click = "pavucontrol";
          };

          network = {
            format-wifi = " {essid}";
            format-ethernet = " {ifname}";
            format-disconnected = "⚠ Disconnected";
            tooltip-format = "{ifname}: {ipaddr}";
          };

          battery = {
            format = "{icon} {capacity}%";
            format-icons = [ "" "" "" "" "" ];
            format-charging = " {capacity}%";
          };

          tray = {
            spacing = 10;
          };
        }];

        style = ''
          * {
            font-family: "Roboto", sans-serif;
            font-size = 13px;
          }

          window#waybar {
            background-color: rgba(30, 30, 46, 0.9);
            color: #cdd6f4;
            border-bottom: 2px solid rgba(127, 200, 255, 0.5);
          }

          #workspaces button {
            padding: 0 8px;
            color: #cdd6f4;
            background-color: transparent;
          }

          #workspaces button.active {
            background-color: rgba(127, 200, 255, 0.3);
            border-radius: 4px;
          }

          #window {
            margin-left: 10px;
            font-weight: bold;
          }

          #clock,
          #pulseaudio,
          #network,
          #battery,
          #tray {
            padding: 0 10px;
            margin: 0 5px;
          }

          #battery.charging {
            color: #a6e3a1;
          }

          #battery.warning:not(.charging) {
            color: #f9e2af;
          }

          #battery.critical:not(.charging) {
            color: #f38ba8;
          }
        '';
      };

      # Mako notification daemon
      services.mako = {
        enable = true;
        backgroundColor = "#1e1e2e";
        textColor = "#cdd6f4";
        borderColor = "#7fc8ff";
        borderRadius = 8;
        defaultTimeout = 5000;
      };

      # Swayidle for automatic screen locking
      services.swayidle = {
        enable = true;
        timeouts = [
          {
            timeout = 300;
            command = "${pkgs.swaylock}/bin/swaylock -f";
          }
          {
            timeout = 600;
            command = "${pkgs.systemd}/bin/systemctl suspend";
          }
        ];
      };
    };
}
