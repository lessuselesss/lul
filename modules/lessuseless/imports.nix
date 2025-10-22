{ inputs, ... }:
{
  # home.file.".nix-flake".source = inputs.self.outPath;
  flake.modules.homeManager.lessuseless.imports = [
    inputs.self.modules.homeManager.nix-index
    inputs.self.modules.homeManager.nix-registry
    inputs.self.modules.homeManager.vscode-server
  ];
}
