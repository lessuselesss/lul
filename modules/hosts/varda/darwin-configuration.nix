{ inputs, ... }:
{
  flake.modules.darwin.varda.imports = with inputs.self.modules.darwin; [
    lessuseless
    { users.users.lessuseless.home = "/Users/lessuseless"; }
  ];
}
