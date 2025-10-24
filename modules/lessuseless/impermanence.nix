{ inputs, ... }:
{
  # Import home-manager impermanence module
  flake.modules.homeManager.lessuseless = {
    imports = [ inputs.impermanence.homeManagerModules.impermanence ];

    # User-specific impermanence configuration
    home.persistence."/persist/home/lessuseless" = {
      directories = [
        # User data
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"

        # Dotfiles managed by stow/home-manager
        "dotfiles"

        # SSH keys (restricted permissions)
        ".ssh"

        # === BROWSERS ===
        # Firefox - full persistence
        ".mozilla/firefox"          # Firefox sessions, cookies, passwords

        # Qutebrowser - granular persistence (sessions & cookies only)
        ".local/share/qutebrowser/sessions"        # Tab sessions
        ".local/share/qutebrowser/webengine/Cookies"  # Cookies only
        # Note: Config, history, bookmarks are ephemeral (fresh each boot)

        # Chromium - full persistence for convenience
        ".config/chromium"          # Full chromium data (profiles, extensions, etc)

        # === SESSIONS & AUTH ===
        ".local/share/keyrings"     # GNOME keyring (passwords for apps)

        # === DEVELOPMENT ===
        ".local/share/direnv"       # direnv allowed directories
        ".config/gh"                # GitHub CLI authentication
        ".local/share/fish"         # Fish shell history & data

        # === PERFORMANCE ===
        ".cache/nix"                # Nix evaluation cache (faster rebuilds)

        # Add more as needed:
        # ".config/discord"         # Discord sessions
        # ".config/Code"            # VS Code settings & extensions
        # ".vscode"                 # VS Code workspace data
        # ".local/share/Steam"      # Steam library & settings
      ];

      files = [
        ".bash_history"
      ];

      allowOther = true;  # Required for some applications
    };
  };
}
