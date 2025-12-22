{ inputs, ... }:
let
  lessuseless_at =
    host:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.self.nixosConfigurations.${host}.pkgs;
      modules = [ inputs.self.homeModules.lessuseless ];
      extraSpecialArgs.osConfig = inputs.self.nixosConfigurations.${host}.config;
    };
in
{
  flake.homeConfigurations.lessuseless = lessuseless_at "tachi";
  flake.homeConfigurations."lessuseless@tachi" = lessuseless_at "tachi";

  flake.homeModules.lessuseless.imports = [
    inputs.self.modules.homeManager.lessuseless
  ];

  flake.modules.homeManager.lessuseless =
    { pkgs, lib, ... }:
    {
      home.username = lib.mkDefault "lessuseless";
      home.homeDirectory = lib.mkDefault (
        if pkgs.stdenvNoCC.isDarwin then "/Users/lessuseless" else "/home/lessuseless"
      );
      home.stateVersion = lib.mkDefault "25.05";
    };
}
