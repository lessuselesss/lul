{ inputs, ... }:
let

  flake-file.inputs.sops-nix.url = "github:Mic92/sops-nix";

  flake.modules.homeManager.lessuseless =
    {
      config,
      pkgs,
      ...
    }:
    {

      imports = [
        inputs.sops-nix.homeManagerModules.sops
      ];

      home.packages = [ pkgs.sops ];

      sops = {
        # Use age keys (backed up to Ventoy)
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        age.generateKey = true;  # Auto-generate if missing
        age.sshKeyPaths = [ ];

        # Disable GPG
        gnupg.home = null;
        gnupg.sshKeyPaths = [ ];

        defaultSopsFile = ./secrets.yaml;
        validateSopsFiles = false;  # Disable until we set up new keys

        secrets = {
          "hello" = { };
          "groq_api_key" = { };
          "gemini_eco_key" = { };
          "copilot_api_key" = { };
          "anthropic_api_key" = { };

          # SSH private keys (binary secrets)
          "ssh/id_ed25519" = {
            format = "binary";
            sopsFile = ./secrets/tachi;
          };
          "ssh/gh_ed25519" = {
            format = "binary";
            sopsFile = ./secrets/gh_ed25519;
          };
          "ssh/localhost_run" = {
            format = "binary";
            sopsFile = ./secrets/localhost_run;
          };

          # Other binary secrets (commented for reference)
          # "edge.token" = {
          #   format = "binary";
          #   sopsFile = ./secrets/edge.token;
          # };
          # "ssh/sops_ssh_config" = {
          #   format = "binary";
          #   sopsFile = ./secrets/ssh-conf;
          # };
        };

        templates = {
          "hello.toml".content = ''
            hello = "Wooo ${config.sops.placeholder.hello} Hoo";
          '';
          "llm_apis.env".content = ''
            GEMINI_API_KEY="${config.sops.placeholder.gemini_eco_key}"
            OPENAI_API_KEY="${config.sops.placeholder.copilot_api_key}"
            ANTHROPIC_API_KEY="${config.sops.placeholder.anthropic_api_key}"
            GROQ_API_KEY="${config.sops.placeholder.groq_api_key}"
          '';
        };
      };

    };
in
{
  inherit flake-file;
  inherit flake;
}
