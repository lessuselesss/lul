let
  flake.modules.homeManager.lessuseless =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false; # Explicitly manage defaults
        # DISABLED: sops ssh config not set up yet
        # includes = [ "~/.config/sops-nix/secrets/ssh/sops_ssh_config" ];

        matchBlocks = {
          # Default configuration for all hosts
          "*" = {
            addKeysToAgent = "yes";
            controlMaster = "auto";
            controlPath = "~/.ssh/socket-%r@%h:%p";
            controlPersist = "10m";
          };

          "github.com" = {
            identityFile = "~/.ssh/gh_ed25519";
            controlPersist = "no"; # Override default
          };

          "edge" = {
            host = "edge";
            hostname = "192.168.192.168";
          };

          "uptermd.upterm.dev" = {
            forwardAgent = true;
            serverAliveInterval = 10;
            serverAliveCountMax = 6;
            extraOptions.ControlPath = "~/.ssh/upterm-%C";
            setEnv.TERM = "xterm-256color";
            localForwards = [
              {
                bind.port = 8000; # http
                host.address = "127.0.0.1";
                host.port = 8000;
              }
              {
                bind.port = 5900; # vnc
                host.address = "127.0.0.1";
                host.port = 5900;
              }
            ];
            remoteForwards = [
              {
                bind.port = 5000; # sops
                host.address = "127.0.0.1";
                host.port = 5000;
              }
            ];
          };

        };
      };

      services.ssh-agent.enable = pkgs.stdenv.isLinux;

      # Link SOPS-encrypted SSH private keys to ~/.ssh
      home.activation.link-ssh-id = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        $DRY_RUN_CMD mkdir -p $HOME/.ssh
        $DRY_RUN_CMD chmod 700 $HOME/.ssh
        run ln -sf "${config.sops.secrets."ssh/id_ed25519".path}" $HOME/.ssh/id_ed25519
        run ln -sf "${config.sops.secrets."ssh/gh_ed25519".path}" $HOME/.ssh/gh_ed25519
        run ln -sf "${config.sops.secrets."ssh/localhost_run".path}" $HOME/.ssh/id_localhost_run
      '';
    };
in
{
  inherit flake;
}
