{ inputs, ... }:
let
  flake.modules.homeManager.lessuseless = {
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    home.file.".config/direnv/lib/use_nix_installables.sh".text = use_nix_installables;
    home.file.".config/direnv/lib/use_vix_go.sh".text = use_vix_go;
    home.file.".config/direnv/lib/use_vix_llm.sh".text = use_vix_llm;
    home.file.".envrc".text = home_envrc;

  };

  use_nix_installables = ''
    use_nix_installables() {
      direnv_load nix shell "''${@}" -c $direnv dump
    }
  '';

  use_vix_go = ''
    use_vix_go() {
      use nix_installables ${inputs.nixpkgs}#go ${inputs.nixpkgs}#gopls
    }
  '';

  use_vix_llm = ''
    use_vix_llm() {
      source $HOME/.config/sops-nix/secrets/rendered/llm_apis.env
      export GEMINI_API_KEY
      export GOOGLE_AI_API_KEY="''${GEMINI_API_KEY}"
      # export OPENAI_API_KEY
      # export OPENAI_API_BASE="https://api.githubcopilot.com"
      # export ANTHROPIC_API_KEY
      # export GROQ_API_KEY
    }
  '';

  home_envrc = ''
    use vix_llm
  '';

in
{
  inherit flake;
}
