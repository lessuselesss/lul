{ lib, ... }:
{
  flake.modules.nixos.niri-desktop =
    { pkgs, config, ... }:
    {
      # Enable niri compositor
      programs.niri.enable = true;

      # System packages needed for niri
      environment.systemPackages = with pkgs; [
        niri
        xwayland-satellite  # XWayland support for niri
        fuzzel              # Application launcher
        waybar              # Status bar
        swaylock            # Screen locker
        swayidle            # Idle management
        swaybg              # Wallpaper daemon
        mako                # Notification daemon
        grim                # Screenshot tool
        slurp               # Region selector
        wl-clipboard        # Clipboard utilities
        kanshi              # Display configuration
        brightnessctl       # Brightness control
        pavucontrol         # Volume control GUI
      ];

      # XDG portal for screen sharing and other desktop integration
      xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gnome  # Reuse GNOME portal
          xdg-desktop-portal-gtk
        ];
      };

      # Enable required services
      services.dbus.enable = true;
      security.polkit.enable = true;

      # GNOME Keyring PAM integration for auto-unlock
      services.gnome.gnome-keyring.enable = true;

      # Display manager integration
      services.displayManager.sessionPackages = [ pkgs.niri ];
      services.displayManager.defaultSession = lib.mkForce "niri";
    };
}
