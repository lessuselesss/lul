# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  description = "Vic's Nix Environment";

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  nixConfig = {
    allow-import-from-derivation = true;
    extra-substituters = [ "https://lul.cachix.org" ];
    extra-trusted-public-keys = [ "lul.cachix.org-1:du306UACvYmVfHgEtPd2XoPszPmgB9UyWk3iB+6ZYwE=" ];
  };

  inputs = {
    SPC.url = "github:vic/SPC";
    antigravity-nix.url = "github:fdiblen/antigravity-nix";
    devshell.url = "github:numtide/devshell";
    disko = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/disko";
    };
    doom-emacs = {
      flake = false;
      url = "github:doomemacs/doomemacs";
    };
    edgevpn = {
      flake = false;
      url = "github:mudler/edgevpn";
    };
    flake-file.url = "github:vic/flake-file";
    flake-parts = {
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
      url = "github:hercules-ci/flake-parts";
    };
    home-manager.url = "github:nix-community/home-manager";
    impermanence.url = "github:nix-community/impermanence";
    import-tree.url = "github:vic/import-tree";
    jjui.url = "github:idursun/jjui";
    nix-ai-tools.url = "github:lessuselesss/nix-ai-tools";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-wallpaper.url = "github:lunik1/nix-wallpaper";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-lib.follows = "nixpkgs";
    preservation.url = "github:nix-community/preservation";
    sops-nix.url = "github:Mic92/sops-nix";
    systems.url = "github:nix-systems/default";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

}
