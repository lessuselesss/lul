{ inputs, ... }:
{

  imports = [
    inputs.flake-file.flakeModules.dendritic
    # den is automatically enabled by dendritic
  ];

  flake-file.inputs = {
    flake-file.url = "github:vic/flake-file";
    den.url = "github:vic/den";
  };

}
