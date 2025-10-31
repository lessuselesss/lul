{ inputs, lib, ... }:
let
  # Helper to create symlinked directory entries
  withSymlink = dir: {
    directory = dir;
    method = "symlink";
  };
in
{
  # Import home-manager impermanence module
  flake.modules.homeManager.lessuseless = {
    imports = [ inputs.impermanence.homeManagerModules.impermanence ];

    # User-specific impermanence configuration
    # See: https://github.com/nix-community/impermanence/issues/263
    #
    # AUDIT APPROACH: Everything is persisted individually for now.
    # TODO: Incrementally migrate configs to home-manager and remove from persistence
    # Keep time-sensitive data (sessions, cookies, auth tokens) even after migration
    home.persistence."/persist/home/lessuseless" = {
      directories = [
        # === Standard folders (non-dot directories in ~/) ===
        (withSymlink "Downloads")
        (withSymlink "Music")
        (withSymlink "Pictures")
        (withSymlink "Documents")
        (withSymlink "Videos")
        (withSymlink "Desktop")
        (withSymlink "Public")
        (withSymlink "Templates")
        (withSymlink "Projects")
        (withSymlink "dotfiles")
        (withSymlink "backups")

        # NOTE: Top-level dot directories like .cargo, .mozilla, .ssh are NOT persisted
        # Only subdirectories WITHIN dot directories are persisted below

        # === .config subdirectories (alphabetically) ===
        # TODO: Mark which are managed by home-manager vs runtime state
        (withSymlink ".config/BeeperTexts")     # TODO: check if HM manages
        (withSymlink ".config/chromium")        # Browser - HM manages extensions, keep for sessions/cookies
        (withSymlink ".config/claude")          # Claude CLI config
        (withSymlink ".config/Code")            # VS Code - HM manages settings.json/keybindings.json, keep for extensions state
        (withSymlink ".config/configstore")     # Runtime app configs
        (withSymlink ".config/Cursor")          # Cursor editor - HM manages settings, keep for state
        (withSymlink ".config/dconf")           # GTK/GNOME settings - HM may manage
        (withSymlink ".config/direnv")          # TODO: Check if HM manages
        # .config/doom - managed by HM via dots.nix (symlink), don't persist
        (withSymlink ".config/emacs")           # Emacs runtime state (doom uses this)
        (withSymlink ".config/enchant")         # Spell checking config
        (withSymlink ".config/environment.d")   # Environment variables
        (withSymlink ".config/evolution")       # Evolution email
        (withSymlink ".config/fish")            # Fish shell - HM manages config, keep for history/variables
        (withSymlink ".config/gh")              # GitHub CLI - OAuth tokens (secrets)
        # .config/ghostty - managed by HM via dots.nix (symlink), don't persist
        (withSymlink ".config/ghostty.backup")  # Backup of ghostty config
        (withSymlink ".config/git")             # Git config - TODO: check if HM manages
        (withSymlink ".config/go")              # Go language config
        (withSymlink ".config/google-chrome")   # Chrome browser
        (withSymlink ".config/helix")           # Helix editor
        (withSymlink ".config/jj")              # Jujutsu VCS
        (withSymlink ".config/jjui")            # Jujutsu UI - HM manages config.toml
        (withSymlink ".config/luakit")          # Luakit browser
        (withSymlink ".config/lul")             # THIS REPO - flake config
        (withSymlink ".config/lul-bak")         # Backup of lul config
        (withSymlink ".config/lul-old-new")     # Backup of lul config
        # .config/niri - managed by HM via dots.nix (symlink), don't persist
        (withSymlink ".config/nix")             # Nix config - HM manages nix.conf, keep for runtime
        # .config/nvim - managed by HM via dots.nix (symlink), don't persist
        (withSymlink ".config/pulse")           # PulseAudio settings
        (withSymlink ".config/quickshell")      # Quickshell config
        (withSymlink ".config/qutebrowser")     # Qutebrowser - HM manages config.py, keep for sessions
        (withSymlink ".config/sops")            # SOPS age keys (secrets)
        (withSymlink ".config/sops-nix")        # SOPS-nix state
        (withSymlink ".config/systemd")         # User systemd services - HM may create services here
        (withSymlink ".config/television")      # Television app
        # .config/wezterm - managed by HM via dots.nix (symlink), don't persist
        # .config/zed - managed by HM via dots.nix (symlink), don't persist

        # === .config files (not directories) ===
        # Handled in files = [ ] section below

        # === .local/share subdirectories ===
        (withSymlink ".local/share/applications")    # Desktop entries
        (withSymlink ".local/share/containers")      # Podman/container storage
        (withSymlink ".local/share/DankMaterialShell") # Shell theme
        (withSymlink ".local/share/direnv")          # Direnv allowed directories
        (withSymlink ".local/share/doom")            # Doom Emacs packages
        (withSymlink ".local/share/fish")            # Fish shell history
        (withSymlink ".local/share/flatpak")         # Flatpak apps
        (withSymlink ".local/share/keyrings")        # GNOME keyring (passwords)
        (withSymlink ".local/share/luakit")          # Luakit browser data
        (withSymlink ".local/share/nvim")            # Neovim plugins/state
        (withSymlink ".local/share/qutebrowser")     # Qutebrowser sessions/cookies
        (withSymlink ".local/share/TelegramDesktop") # Telegram app data
        (withSymlink ".local/share/television")      # Television app data
        (withSymlink ".local/share/uv")              # UV Python tool
        (withSymlink ".local/share/zed")             # Zed editor extensions/state

        # === .local/state subdirectories ===
        (withSymlink ".local/state/DankMaterialShell") # Shell theme state
        (withSymlink ".local/state/home-manager")      # Home-manager state
        (withSymlink ".local/state/nix")               # Nix profiles/generations
        (withSymlink ".local/state/nvim")              # Neovim state
        (withSymlink ".local/state/wireplumber")       # Wireplumber audio state
        (withSymlink ".local/state/yazi")              # Yazi file manager

        # === .cache subdirectories (important caches only) ===
        # Most caches can regenerate, but some are expensive or contain sessions
        (withSymlink ".cache/chromium")        # Browser cache (sessions may be here)
        (withSymlink ".cache/nix")             # Nix evaluation cache (faster rebuilds)
        (withSymlink ".cache/nix-index")       # nix-locate database (30min to rebuild)
        (withSymlink ".cache/spotify")         # Spotify downloaded music + keys
        (withSymlink ".cache/uv")              # UV Python tool cache

        # === .anydesk subdirectories ===
        (withSymlink ".anydesk/cache")         # AnyDesk connection cache
        (withSymlink ".anydesk/global_cache")  # AnyDesk global cache data

        # === .claude subdirectories ===
        (withSymlink ".claude/debug")          # Claude CLI debug logs
        (withSymlink ".claude/file-history")   # Claude file operation history
        (withSymlink ".claude/plugins")        # Claude CLI plugins
        (withSymlink ".claude/projects")       # Claude project data
        (withSymlink ".claude/session-env")    # Claude session environment data
        (withSymlink ".claude/shell-snapshots") # Claude shell state snapshots
        (withSymlink ".claude/statsig")        # Claude analytics/telemetry
        (withSymlink ".claude/todos")          # Claude TODO tracking data

        # === .gemini subdirectories ===
        (withSymlink ".gemini/tmp")            # Gemini temporary files

        # === .gnupg subdirectories ===
        (withSymlink ".gnupg/private-keys-v1.d") # GPG private key storage (SECRETS)

        # === .mozilla subdirectories ===
        (withSymlink ".mozilla/firefox")       # Firefox profiles (bookmarks, history, passwords)

        # === .npm subdirectories ===
        (withSymlink ".npm/_cacache")          # NPM package cache (saves bandwidth)
        (withSymlink ".npm/_logs")             # NPM installation logs
        (withSymlink ".npm/_npx")              # NPX binary cache

        # === .pki subdirectories ===
        (withSymlink ".pki/nssdb")             # NSS certificate database (Chrome/Firefox certs)

        # === .cursor subdirectories ===
        (withSymlink ".cursor/extensions")     # Cursor editor extensions

        # === .vscode subdirectories ===
        (withSymlink ".vscode/extensions")     # VS Code extensions

        # === .vscode-server subdirectories ===
        (withSymlink ".vscode-server/bin")     # VS Code remote server binaries
        (withSymlink ".vscode-server/cli")     # VS Code remote CLI tools
      ];
      files = [
        # === Dotfiles at ~/ root ===
        ".bash_history"                        # Bash command history
        ".zsh_history"                         # Zsh command history

        # === .config files (EXCEPTION: .config has special rule - only these files) ===
        # NOTE: .config/mimeapps.list - managed by home-manager elsewhere, don't persist
        ".config/pavucontrol.ini"              # PulseAudio volume control settings

        # === .anydesk files ===
        ".anydesk/.anydesk.trace"              # AnyDesk trace log
        ".anydesk/anydesk.trace"               # AnyDesk trace log (no dot prefix)
        ".anydesk/connection_trace.txt"        # AnyDesk connection trace
        ".anydesk/.iid"                        # AnyDesk installation ID
        ".anydesk/service.conf"                # AnyDesk service configuration
        ".anydesk/system.conf"                 # AnyDesk system configuration
        ".anydesk/user.conf"                   # AnyDesk user configuration

        # === .claude files (SECRETS) ===
        ".claude/.credentials.json"            # Claude CLI authentication credentials (SECRET)
        ".claude/history.jsonl"                # Claude CLI command history
        ".claude/settings.json"                # Claude CLI settings
        ".claude/settings.local.json"          # Claude CLI local settings override

        # === .gemini files (SECRETS) ===
        ".gemini/GEMINI.md"                    # Gemini documentation
        ".gemini/google_accounts.json"         # Gemini Google account info
        ".gemini/installation_id"              # Gemini installation ID
        ".gemini/oauth_creds.json"             # Gemini OAuth credentials (SECRET)
        ".gemini/settings.json"                # Gemini settings
        ".gemini/settings.json-bak"            # Gemini settings backup

        # === .gnupg files (SECRETS) ===
        # NOTE: .gnupg/gpg-agent.conf, gpg.conf, scdaemon.conf - managed by home-manager, don't persist
        ".gnupg/sshcontrol"                    # GPG SSH key control

        # === .nix-defexpr files ===
        ".nix-defexpr/channels"                # Nix user channel definitions (symlink)
        ".nix-defexpr/channels_root"           # Nix root channel definitions (symlink)

        # === .npm files ===
        ".npm/_update-notifier-last-checked"   # NPM update checker timestamp

        # === .ssh files (SECRETS) ===
        ".ssh/authorized_keys"                 # SSH authorized public keys
        ".ssh/config"                          # SSH client configuration
        ".ssh/gh_ed25519"                      # GitHub SSH private key (SECRET)
        ".ssh/gh_ed25519.pub"                  # GitHub SSH public key
        ".ssh/gh_ed25519.pub.backup"           # GitHub SSH public key backup
        ".ssh/id_ed25519"                      # Default SSH private key (SECRET)
        ".ssh/id_ed25519.pub"                  # Default SSH public key
        ".ssh/id_ed25519.pub.backup"           # Default SSH public key backup
        ".ssh/id_localhost_run"                # Localhost run SSH private key (SECRET)
        ".ssh/id_localhost_run.pub"            # Localhost run SSH public key
        ".ssh/known_hosts"                     # SSH known hosts fingerprints
        ".ssh/known_hosts.old"                 # SSH known hosts backup
        ".ssh/nix_versions_ed25519.pub"        # Nix versions SSH public key
        ".ssh/vix_ed25519.pub"                 # Vix SSH public key

        # === .w3m files ===
        ".w3m/history"                         # w3m browser history
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
