{ inputs, ... }:
{
  # Den host inventory for tachi
  den.hosts.x86_64-linux.tachi = {
    description = "Intel 11th Gen i7-1165G7 laptop with Niri desktop";

    users.lessuseless = {
      aspect = "lessuseless";
    };
  };
}
