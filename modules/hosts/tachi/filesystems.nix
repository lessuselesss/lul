# Filesystem configuration now handled by disko-config.nix
# This file kept for reference but can be removed
# Disko will automatically generate filesystem configurations
# based on the declarative disk layout defined in disko-config.nix
{
  flake.modules.nixos.tachi = {
    # No filesystem definitions needed - handled by disko
    # No swap devices configured
  };
}
