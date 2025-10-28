{
  flake.modules.homeManager.lessuseless =
    { config, pkgs, ... }:
    let
      dotsLink =
        path:
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.flake/modules/lessuseless/dots/${path}";
    in
    {
      home.activation.link-flake = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        echo Checking that "$HOME/.flake" exists.
        if ! test -L "$HOME/.flake"; then
          echo "Missing $HOME/.flake link"
          exit 1
        fi
      '';

      # SSH public keys (private keys are managed by SOPS in secrets.nix)
      home.file.".ssh/authorized_keys".source = dotsLink "ssh/authorized_keys";
      home.file.".ssh/gh_ed25519.pub".source = dotsLink "ssh/gh_ed25519.pub";
      home.file.".ssh/id_ed25519.pub".source = dotsLink "ssh/id_ed25519.pub";
      home.file.".ssh/id_localhost_run.pub".source = dotsLink "ssh/id_localhost_run.pub";
      home.file.".ssh/nix_versions_ed25519.pub".source = dotsLink "ssh/nix_versions_ed25519.pub";
      home.file.".ssh/vix_ed25519.pub".source = dotsLink "ssh/vix_ed25519.pub";

      home.file.".config/niri".source = dotsLink "config/niri";
      home.file.".config/nvim".source = dotsLink "config/nvim";
      home.file.".config/doom".source = dotsLink "config/doom";
      home.file.".config/zed".source = dotsLink "config/zed";
      home.file.".config/wezterm".source = dotsLink "config/wezterm";
      home.file.".config/ghostty".source = dotsLink "config/ghostty";

      home.file.".config/Code/User/settings.json".source = dotsLink "config/Code/User/settings.json";
      home.file.".config/Code/User/keybindings.json".source =
        dotsLink "config/Code/User/keybindings.json";
      home.file.".vscode/extensions/extensions.json".source =
        dotsLink "vscode/extensions/extensions-${pkgs.stdenv.hostPlatform.uname.system}.json";

      home.file.".config/Cursor/User/settings.json".source = dotsLink "config/Code/User/settings.json";
      home.file.".config/Cursor/User/keybindings.json".source =
        dotsLink "config/Code/User/keybindings.json";
      home.file.".cursor/extensions/extensions.json".source =
        dotsLink "cursor/extensions/extensions-${pkgs.stdenv.hostPlatform.uname.system}.json";

    };
}
