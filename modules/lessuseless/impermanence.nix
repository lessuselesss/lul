{
  flake.modules.nixos.lessuseless = {
    # User-specific impermanence configuration
    environment.persistence."/persist" = {
      users.lessuseless = {
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
          {
            directory = ".ssh";
            mode = "0700";
          }

          # Application data directories (add as needed)
          # ".local/share/direnv"
          # ".mozilla/firefox"
          # ".config/discord"
          # ".local/share/Steam"
        ];

        files = [
          ".bash_history"
        ];
      };
    };
  };
}
