{ inputs, ... }:
{
  flake.modules.darwin.yavanna.imports = with inputs.self.modules.darwin; [
    lessuseless
    { users.users.lessuseless.home = "/Users/lessuseless"; }
  ];

}
