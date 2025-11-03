{ inputs, ... }:
let
  inherit (inputs.self.lib.mk-os)
    wsl
    linux
    linux-arm
    darwin
    darwin-intel
    ;

  flake.nixosConfigurations = {
    # Upstream vix hosts (commented out - not owned)
    # annatar = wsl "annatar";
    # mordor = linux "mordor";
    # nargun = linux "nargun";
    # smaug = linux "smaug";
    # nienna = linux "nienna";
    tachi = linux "tachi";
    # tom = linux "tom";
    # bombadil = linux "bombadil";
    # bill = linux-arm "bill";
  };

  flake.darwinConfigurations = {
    # Upstream vix hosts (commented out - not owned)
    # yavanna = darwin-intel "yavanna";
    # varda = darwin "varda";
    # bert = darwin "bert";
  };

in
{
  inherit flake;
}
