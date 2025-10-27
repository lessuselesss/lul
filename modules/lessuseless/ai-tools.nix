{ inputs, ... }:
let
  flake-file.inputs = {
    nix-ai-tools.url = "github:lessuselesss/nix-ai-tools";
  };

  flake.modules.homeManager.lessuseless.imports = [ ai-tools ];

  ai-tools =
    { pkgs, ... }:
    let
      ai-pkgs = inputs.nix-ai-tools.packages.${pkgs.system};
    in
    {
      home.packages = [
        ai-pkgs.claude-code
        ai-pkgs.llm
        ai-pkgs.gemini-cli
        ai-pkgs.qwen-code
      ];
    };

in
{
  inherit flake flake-file;
}
