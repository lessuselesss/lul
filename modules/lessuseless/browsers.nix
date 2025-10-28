{ inputs, ... }:
let
  # Import browser profile definitions
  quteProfiles = import ./_browsers/qutebrowser-profiles.nix;
  chromeProfiles = import ./_browsers/chromium-profiles.nix;
in
{
  flake.modules.homeManager.lessuseless =
    { config, pkgs, lib, ... }:
    {
      # Qutebrowser - keyboard-driven, minimal
      programs.qutebrowser = {
        enable = true;

        # Load balances (search engines, quickmarks, etc)
        loadAutoconfig = false;

        searchEngines = {
          DEFAULT = "https://search.nixos.org/packages?channel=unstable&query={}";
          g = "https://www.google.com/search?q={}";
          gh = "https://github.com/search?q={}";
          nw = "https://nixos.wiki/index.php?search={}";
          yt = "https://www.youtube.com/results?search_query={}";
          ddg = "https://duckduckgo.com/?q={}";
        };

        quickmarks = {
          nixpkgs = "https://github.com/NixOS/nixpkgs";
          hm = "https://github.com/nix-community/home-manager";
          nixos = "https://nixos.org";
        };

        settings = {
          # UI
          tabs.show = "multiple";
          tabs.position = "top";
          statusbar.show = "in-mode";

          # Content
          content.autoplay = false;
          content.javascript.clipboard = "access-paste";

          # Privacy (more restrictive)
          content.cookies.accept = "no-3rdparty";
          content.headers.do_not_track = true;
          content.geolocation = false;

          # Downloads
          downloads.location.directory = "~/Downloads";
          downloads.location.prompt = false;

          # Hints (link following)
          hints.chars = "asdfghjkl";

          # Colors (adjust to your theme)
          colors.webpage.darkmode.enabled = false;
        };

        keyBindings.normal = {
          # Custom keybindings
          ",p" = "spawn --userscript qute-pass";
          ",m" = "hint links spawn mpv {hint-url}";
          ",M" = "spawn mpv {url}";
          ",d" = "download";
        };

        # Enable spell checking
        extraConfig = ''
          c.spellcheck.languages = ["en-US"]

          # Per-domain settings
          config.set('content.javascript.enabled', True, 'https://github.com/*')
          config.set('content.javascript.enabled', True, 'https://nixos.org/*')
        '';
      };

      # Chromium - full-featured for sites that need it
      programs.chromium = {
        enable = true;

        # Extensions (IDs from Chrome Web Store)
        extensions = [
          { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
          { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
          { id = "kkhfnlkhiapbiehimabddjbimfaijdhk"; } # Gopass Bridge
        ];

        commandLineArgs = [
          # Privacy
          "--enable-features=WebUIDarkMode"
          "--force-dark-mode"

          # Performance
          "--enable-gpu-rasterization"
          "--enable-zero-copy"
        ];
      };

      # Fish shell integration
      programs.fish.shellAbbrs = {
        q = "qutebrowser";
        qb = "qutebrowser";
        chr = "chromium";
      };
    };
}
