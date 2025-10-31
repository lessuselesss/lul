{

  flake-file = {
    description = "Vic's Nix Environment";

    nixConfig = {
      allow-import-from-derivation = true;
      extra-trusted-public-keys = [
        "lul.cachix.org-1:du306UACvYmVfHgEtPd2XoPszPmgB9UyWk3iB+6ZYwE="
      ];
      extra-substituters = [ "https://lul.cachix.org" ];
    };
  };

}
