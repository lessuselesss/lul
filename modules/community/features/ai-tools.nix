{ inputs, lib, ... }:
{
  flake-file.inputs = {
    nix-ai-tools.url = "github:lessuselesss/nix-ai-tools";
  };

  flake.modules.nixos.ai-tools =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.ai-tools;
      ai-pkgs = inputs.nix-ai-tools.packages.${pkgs.system};
    in
    {
      options.features.ai-tools = {
        enable = lib.mkEnableOption "AI coding tools";

        packages = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "claude-code"
            "llm"
          ];
          description = ''
            List of AI tools to install from nix-ai-tools.
            Available tools: amp, backlog-md, catnip, claude-code, claude-code-router,
            claude-desktop, claudebox, code, coderabbit-cli, codex, codex-acp,
            copilot-cli, crush, cursor-agent, droid, forge, gemini-cli, goose-cli,
            groq-code-cli, llm, nanocoder, opencode, qwen-code
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = map (name: ai-pkgs.${name}) cfg.packages;
      };
    };

  flake.modules.darwin.ai-tools =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.ai-tools;
      ai-pkgs = inputs.nix-ai-tools.packages.${pkgs.system};
    in
    {
      options.features.ai-tools = {
        enable = lib.mkEnableOption "AI coding tools";

        packages = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "claude-code"
            "llm"
          ];
          description = ''
            List of AI tools to install from nix-ai-tools.
            Available tools: amp, backlog-md, catnip, claude-code, claude-code-router,
            claude-desktop, claudebox, code, coderabbit-cli, codex, codex-acp,
            copilot-cli, crush, cursor-agent, droid, forge, gemini-cli, goose-cli,
            groq-code-cli, llm, nanocoder, opencode, qwen-code
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        environment.systemPackages = map (name: ai-pkgs.${name}) cfg.packages;
      };
    };

  flake.modules.homeManager.ai-tools =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.features.ai-tools;
      ai-pkgs = inputs.nix-ai-tools.packages.${pkgs.system};
    in
    {
      options.features.ai-tools = {
        enable = lib.mkEnableOption "AI coding tools";

        packages = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "claude-code"
            "llm"
          ];
          description = ''
            List of AI tools to install from nix-ai-tools.
            Available tools: amp, backlog-md, catnip, claude-code, claude-code-router,
            claude-desktop, claudebox, code, coderabbit-cli, codex, codex-acp,
            copilot-cli, crush, cursor-agent, droid, forge, gemini-cli, goose-cli,
            groq-code-cli, llm, nanocoder, opencode, qwen-code
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = map (name: ai-pkgs.${name}) cfg.packages;
      };
    };
}
