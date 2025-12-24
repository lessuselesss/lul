{ inputs, ... }:
{
  flake-file.inputs = {
    antigravity-nix.url = "github:fdiblen/antigravity-nix";
  };

  flake.modules.homeManager.antigravity =
    { pkgs, ... }:
    {
      home.packages = [
        inputs.antigravity-nix.packages.${pkgs.system}.default
      ];
    };
}
