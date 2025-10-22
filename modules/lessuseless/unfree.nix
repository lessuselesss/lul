{ inputs, ... }:
let
  flake.modules.homeManager.lessuseless.imports = [
    unfree
  ];

  unfree = inputs.self.lib.unfree-module [
    "cursor"
    "vscode"
    "anydesk"
    "copilot-language-server"
  ];
in
{
  inherit flake;
}
