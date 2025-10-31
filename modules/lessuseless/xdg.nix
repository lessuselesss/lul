{ ... }:
{
  flake.modules.homeManager.lessuseless = {
    xdg.mimeApps = {
      enable = true;

      defaultApplications = {
        # Web browsers - using chromium as default
        "text/html" = "chromium-browser.desktop";
        "x-scheme-handler/http" = "chromium-browser.desktop";
        "x-scheme-handler/https" = "chromium-browser.desktop";
        "x-scheme-handler/about" = "chromium-browser.desktop";
        "x-scheme-handler/unknown" = "chromium-browser.desktop";

        # Alternative: Use qutebrowser instead
        # "text/html" = "org.qutebrowser.qutebrowser.desktop";
        # "x-scheme-handler/http" = "org.qutebrowser.qutebrowser.desktop";
        # "x-scheme-handler/https" = "org.qutebrowser.qutebrowser.desktop";

        # Email (uncomment if you install a mail client)
        # "x-scheme-handler/mailto" = "thunderbird.desktop";

        # PDFs
        "application/pdf" = "org.pwmt.zathura.desktop";

        # Images
        "image/png" = "feh.desktop";
        "image/jpeg" = "feh.desktop";
        "image/gif" = "feh.desktop";
      };

      associations.added = {
        # Add qutebrowser as an alternative browser
        "text/html" = [
          "chromium-browser.desktop"
          "org.qutebrowser.qutebrowser.desktop"
        ];
        "x-scheme-handler/http" = [
          "chromium-browser.desktop"
          "org.qutebrowser.qutebrowser.desktop"
        ];
        "x-scheme-handler/https" = [
          "chromium-browser.desktop"
          "org.qutebrowser.qutebrowser.desktop"
        ];
      };
    };

    # Enable XDG user directories
    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "$HOME/Desktop";
      documents = "$HOME/Documents";
      download = "$HOME/Downloads";
      music = "$HOME/Music";
      pictures = "$HOME/Pictures";
      videos = "$HOME/Videos";
    };
  };
}
