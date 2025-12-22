{ ... }:
{
  flake.modules.nixos.lessuseless =
    { pkgs, ... }:
    {
      # Enable GPG with smartcard/hardware key support
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        pinentryPackage = pkgs.pinentry-gnome3; # System-level uses pinentryPackage (not deprecated)
      };

      # Enable smartcard daemon for hardware keys
      services.pcscd.enable = true;

      # USB permissions for hardware keys
      services.udev.packages = [
        pkgs.ledger-udev-rules # Ledger Nano support
      ];

      # Add hardware key tools to system
      environment.systemPackages = with pkgs; [
        gnupg
        pinentry-gnome3
        ledger-live-desktop # Ledger Nano management
        usbutils # For lsusb
        pcsclite # PC/SC smartcard tools
        pcsc-tools # Additional smartcard utilities
      ];
    };

  flake.modules.homeManager.lessuseless =
    { pkgs, ... }:
    {
      # Home-manager GPG configuration
      programs.gpg = {
        enable = true;
        settings = {
          # Use GPG agent for key operations
          use-agent = true;
        };
      };

      # GPG agent configuration
      services.gpg-agent = {
        enable = true;
        enableSshSupport = true;
        pinentry.package = pkgs.pinentry-gnome3; # Updated option name

        # Increase cache time for hardware keys (enter PIN less often)
        defaultCacheTtl = 3600; # 1 hour
        maxCacheTtl = 7200; # 2 hours
      };

      # Add hardware key tools to user environment
      home.packages = with pkgs; [
        yubikey-manager # Generic smartcard management
        age-plugin-yubikey # If you want age + hardware key support
      ];
    };
}
