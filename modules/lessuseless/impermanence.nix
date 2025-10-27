{ inputs, ... }:
{
  # Import home-manager impermanence module
  flake.modules.homeManager.lessuseless = {
    imports = [ inputs.impermanence.homeManagerModules.impermanence ];

    # User-specific impermanence configuration
    # TEMPORARY: Persisting entire home directory for safety during migration
    # TODO: Incrementally uncomment and refine the granular config below
    home.persistence."/persist/home/lessuseless" = {
      directories = [
        # Persist everything - add top-level dirs and common dotfiles
        # Using symlinks instead of bindfs to avoid directories disappearing during rebuilds
        {
          directory = "Downloads";
          method = "symlink";
        }
        {
          directory = "Music";
          method = "symlink";
        }
        {
          directory = "Pictures";
          method = "symlink";
        }
        {
          directory = "Documents";
          method = "symlink";
        }
        {
          directory = "Videos";
          method = "symlink";
        }
        {
          directory = "Desktop";
          method = "symlink";
        }
        {
          directory = "Public";
          method = "symlink";
        }
        {
          directory = "Templates";
          method = "symlink";
        }
        {
          directory = "Projects";
          method = "symlink";
        }
        {
          directory = "dotfiles";
          method = "symlink";
        }
        {
          directory = ".config";
          method = "symlink";
        }
        {
          directory = ".local";
          method = "symlink";
        }
        {
          directory = ".cache";
          method = "symlink";
        }
        {
          directory = ".ssh";
          method = "symlink";
        }
        {
          directory = ".gnupg";
          method = "symlink";
        }
        {
          directory = ".mozilla";
          method = "symlink";
        }
        {
          directory = ".thunderbird";
          method = "symlink";
        }
        {
          directory = ".cargo";
          method = "symlink";
        }
        {
          directory = ".rustup";
          method = "symlink";
        }
        {
          directory = ".npm";
          method = "symlink";
        }
      ];
      files = [
        ".bash_history"
        ".zsh_history"
      ];
      allowOther = true;
    };

    # ORIGINAL GRANULAR CONFIG (commented out for now):
    # home.persistence."/persist/home/lessuseless" = {
    #   directories = [
    #     # User data
    #     "Downloads"
    #     "Music"
    #     "Pictures"
    #     "Documents"
    #     "Videos"
    #
    #     # Dotfiles managed by stow/home-manager
    #     "dotfiles"
    #
    #     # SSH keys (restricted permissions)
    #     ".ssh"
    #
    #     # === BROWSERS ===
    #     # Firefox - full persistence
    #     ".mozilla/firefox"          # Firefox sessions, cookies, passwords
    #
    #     # Qutebrowser - granular persistence (sessions & cookies only)
    #     ".local/share/qutebrowser/sessions"        # Tab sessions
    #     ".local/share/qutebrowser/webengine/Cookies"  # Cookies only
    #     # Note: Config, history, bookmarks are ephemeral (fresh each boot)
    #
    #     # Chromium - full persistence for convenience
    #     ".config/chromium"          # Full chromium data (profiles, extensions, etc)
    #
    #     # === SESSIONS & AUTH ===
    #     ".local/share/keyrings"     # GNOME keyring (passwords for apps)
    #
    #     # === DEVELOPMENT ===
    #     ".local/share/direnv"       # direnv allowed directories
    #     ".config/gh"                # GitHub CLI authentication
    #     ".config/lul"               # NixOS/Darwin/WSL flake configuration
    #     ".local/share/fish"         # Fish shell history & data
    #
    #     # === PERFORMANCE ===
    #     ".cache/nix"                # Nix evaluation cache (faster rebuilds)
    #
    #     # Add more as needed:
    #     # ".config/discord"         # Discord sessions
    #     # ".config/Code"            # VS Code settings & extensions
    #     # ".vscode"                 # VS Code workspace data
    #     # ".local/share/Steam"      # Steam library & settings
    #   ];
    #
    #   files = [
    #     ".bash_history"
    #   ];
    #
    #   allowOther = true;  # Required for some applications
    # };
  };
}
