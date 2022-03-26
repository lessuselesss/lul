{
  pkgs,
  lib,
  USER,
  direnv_dir,
  ...
}:
lib.mkMerge [
  {
    home-manager.users.${USER}.home.file = {
      ".config/direnv/lib/use_vix_env.sh".text = ''
        function use_vix-env() {
          source ~/"${direnv_dir}/$1/env"
        }
      '';
    };
  }
  #,
  {
    home-manager.users.${USER}.home.file = lib.mkMerge (lib.mapAttrsToList
      (name: shell: {
        "${direnv_dir}/${name}".source = lib.mds.shellEnv shell;
      })
      pkgs.pkgShells);
  }
]
