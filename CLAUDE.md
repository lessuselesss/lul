# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a NixOS/Darwin/WSL configuration repository using the **Dendritic Pattern** - a modular approach that automatically generates `flake.nix` from module-defined inputs and auto-discovers all `.nix` files in `./modules/`.

**Key architectural components:**
- [`vic/flake-file`](https://github.com/vic/flake-file): Generates flake.nix from `flake-file.inputs` declarations across modules
- [`vic/import-tree`](https://github.com/vic/import-tree): Auto-discovers and loads all `./modules/**/*.nix` files
- Entry point: `modules/flake/dendritic.nix`

## Repository Structure

```
modules/
├── community/        # Shareable, reusable modules for anyone
│   ├── features/     # Desktop environments, hardware support, platform configs
│   ├── flake/        # Formatter, systems configuration
│   ├── home/         # Home-manager integrations
│   ├── lib/          # Helper functions and utilities
│   └── packages/     # Shared packages (os-rebuild, gh-flake-update)
├── lessuseless/      # Personal user configuration
│   ├── _fish/        # Fish shell config (abbrs, aliases, functions)
│   ├── dots/         # Dotfiles (nvim, doom, vscode, zed, etc)
│   ├── packages/     # Personal packages (sops utilities, edge)
│   └── *.nix         # User modules (git, jujutsu, ssh, etc)
├── hosts/            # Per-host configurations
│   └── [hostname]/   # Each host has configuration.nix or darwin-configuration.nix
└── flake/            # Flake scaffolding (dendritic.nix, osConfigurations.nix)
```

## Module Architecture

### Dendritic Pattern: How Modules Work

1. **Input Declaration**: Modules declare their flake inputs inline:
   ```nix
   { inputs, ... }:
   {
     flake-file.inputs.jjui.url = "github:idursun/jjui";
     # ... rest of module
   }
   ```

2. **Flake Output Declaration**: Modules contribute to flake outputs using the `flake.*` namespace:
   ```nix
   {
     flake.modules.nixos.mymodule = { ... };
     flake.modules.homeManager.mymodule = { ... };
     flake.packages.mypackage = pkgs.writeShellApplication { ... };
   }
   ```

3. **Auto-Discovery**: `import-tree` loads all `.nix` files from `./modules/`, no manual imports needed

4. **Host Registration**: Hosts are registered in `modules/flake/osConfigurations.nix` using helper functions from `modules/community/lib/+mk-os.nix`

### User Configuration Pattern

User modules in `modules/lessuseless/` follow this structure:
- Each `.nix` file defines either `flake.modules.nixos.lessuseless`, `flake.modules.darwin.lessuseless`, or `flake.modules.homeManager.lessuseless`
- The main user module is `user.nix` which imports platform-specific configs
- `home.nix` defines home-manager configurations using helper function `lessuseless_at`

### Host Configuration Pattern

Hosts in `modules/hosts/[hostname]/` import user and feature modules:
```nix
{ inputs, ... }:
{
  flake.modules.nixos.hostname.imports = with inputs.self.modules.nixos; [
    lessuseless     # User configuration
    xfce-desktop    # Desktop environment
    kvm-intel       # Hardware support
  ];
}
```

## Common Commands

### Building and Deploying

```bash
# Rebuild current host (auto-detects hostname)
nix run path:~/.flake#os-rebuild -- switch

# Rebuild specific host
nix run path:~/.flake#os-rebuild -- HOSTNAME switch

# Install NixOS on new machine
nixos-install --root /mnt --flake ~/.flake#HOSTNAME

# Build ISO image (e.g., for bombadil USB installer)
nix build .#nixosConfigurations.bombadil.config.system.build.isoImage

# Check flake
nix flake check
```

### Development Workflow

```bash
# Format all Nix files
nix fmt

# Enter development shell
nix develop

# Update flake inputs
nix flake update

# Update inputs and create PR (automated)
nix run .#gh-flake-update
```

### Secrets Management (SOPS)

```bash
# Rotate all secrets
nix develop .#nixos -c vic-sops-rotate

# Get secrets from key server (initial setup)
nix run .#vic-sops-get -- --keyservice tcp://SERVER:5000 -f SSH_KEY --setup - >> ~/.config/sops/age/keys.txt

# Edit secrets file
sops modules/lessuseless/secrets.yaml
```

Secrets are stored in `modules/lessuseless/secrets/` and `modules/lessuseless/secrets.yaml`.

## Important Conventions

### File Naming
- Files starting with `+` (e.g., `+mk-os.nix`, `+os-rebuild.nix`) are utility/library modules
- Files starting with `_` (e.g., `_fish/`, `_macos-keys.nix`) are supporting/private modules

### Module Imports
- Use `inputs.self.modules.nixos.*` for NixOS modules
- Use `inputs.self.modules.darwin.*` for Darwin modules
- Use `inputs.self.modules.homeManager.*` for home-manager modules
- Modules are auto-discovered, don't add manual imports to a central file

### Flake Regeneration
The `flake.nix` file is auto-generated. To regenerate:
```bash
nix run .#write-flake
```
**Note**: The file header says "DO-NOT-EDIT" - modify module inputs instead.

## Creating a New Host

1. Create directory: `modules/hosts/[hostname]/`
2. Add `configuration.nix` (NixOS) or `darwin-configuration.nix` (macOS):
   ```nix
   { inputs, ... }:
   {
     flake.modules.nixos.hostname.imports = with inputs.self.modules.nixos; [
       lessuseless
       # Add feature modules as needed
     ];
   }
   ```
3. Register in `modules/flake/osConfigurations.nix`:
   ```nix
   flake.nixosConfigurations = {
     hostname = linux "hostname";  # or darwin, wsl, etc.
   };
   ```

## Customizing for Your Own Setup

The original pattern was designed to be forked:

1. Rename `modules/vic/` → `modules/[yourname]/`
2. Update all references to `vic` → `[yourname]` in:
   - User modules (`user.nix`, `home.nix`, etc.)
   - Host configurations
   - Git/jujutsu user info
3. Update `flake.nix` description (or let dendritic regenerate it)
4. Replace hosts in `modules/hosts/` with your machines
5. Update `osConfigurations.nix` with your hosts

The `modules/community/` directory is intentionally kept generic and shareable.

## Working with Dotfiles

Dotfiles in `modules/lessuseless/dots/` are symlinked via `dots.nix`:
- Uses `config.lib.file.mkOutOfStoreSymlink` to link from `~/.flake/modules/lessuseless/dots/`
- Allows editing dotfiles without rebuilding
- Requires `~/.flake` symlink to point to this repository

## CI/CD

GitHub Actions workflows:
- `build-systems.yaml`: Builds all host configurations
- `flake-update.yaml`: Auto-updates flake inputs
- `sops-rotate-reminder.yaml`: Reminds to rotate secrets
- `nix-fmt.yaml`: Checks formatting

Cachix is configured for binary caching (currently using upstream cache).
