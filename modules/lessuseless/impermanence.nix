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
        "Downloads" "Music" "Pictures" "Documents" "Videos" "Desktop" "Public" "Templates"
        "Projects" "dotfiles"
        ".config" ".local" ".cache" ".ssh" ".gnupg" ".mozilla" ".thunderbird"
        ".cargo" ".rustup" ".npm"
      ];
      files = [ ".bash_history" ".zsh_history" ];
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
