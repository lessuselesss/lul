# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a NixOS/Darwin/WSL configuration repository using the **Dendritic Pattern** with the **Den Pattern** - an aspect-oriented approach for organizing host and user configurations.

**Key architectural components:**
- [`vic/flake-file`](https://github.com/vic/flake-file): Generates flake.nix from `flake-file.inputs` declarations across modules
- [`vic/import-tree`](https://github.com/vic/import-tree): Auto-discovers and loads all `./modules/**/*.nix` files
- [`vic/den`](https://github.com/vic/den): Aspect-oriented host/user configuration system
- Entry point: `modules/flake/dendritic.nix` (automatically enables den)

## Repository Structure

```
modules/
├── aspects/          # Den pattern: aspect-oriented configurations
│   ├── default.nix   # Global defaults for all hosts/users/home
│   ├── features/     # Feature aspects (preservation, impermanence, disko, niri-desktop, kvm-intel)
│   ├── lessuseless.nix  # User aspect for lessuseless
│   └── tachi.nix     # Host aspect for tachi
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
│   └── [hostname]/   # Host-specific configs (preservation.nix, etc)
└── flake/            # Flake scaffolding
    ├── dendritic.nix # Entry point (enables den automatically)
    └── hosts.nix     # Host inventory (den.hosts registration)
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

4. **Host Registration**: Hosts are registered using the den pattern (see below)

### Den Pattern: Aspect-Oriented Configuration

The repository uses the **den pattern** for organizing hosts, users, and configurations through aspects. Aspects are composable configuration modules.

**Aspect Structure:**
```nix
{ inputs, ... }:
{
  flake.aspects = { aspects, ... }: {
    # Global defaults applied to all hosts/users
    default.host.nixos = { system.stateVersion = "25.11"; };
    default.host.darwin = { system.stateVersion = 6; };
    default.home.homeManager = { lib, ... }: {
      home.stateVersion = lib.mkDefault "25.05";
    };

    # Host aspect (tachi example)
    tachi.includes = { flake, ... }: with flake.aspects; [
      preservation  # Feature aspects
      impermanence
      niri-desktop
    ];
    tachi.nixos = { config, ... }: {
      networking.hostName = "tachi";
      imports = [ ../hosts/tachi/preservation.nix ];
    };

    # User aspect (lessuseless example)
    lessuseless.nixos = { pkgs, ... }: {
      users.users.lessuseless = {
        isNormalUser = true;
        shell = pkgs.fish;
      };
    };
    lessuseless.homeManager = {
      imports = [ inputs.self.modules.homeManager.lessuseless ];
    };

    # Feature aspect (impermanence example)
    # NOTE: Only provides NixOS-level support, no environment.persistence
    impermanence.nixos = {
      fileSystems."/persist".neededForBoot = true;
      users.mutableUsers = false;
      programs.fuse.userAllowOther = true;
    };
  };
}
```

**Host Registration** in `modules/flake/hosts.nix`:
```nix
{ inputs, ... }:
{
  den.hosts.x86_64-linux.tachi = {
    description = "Intel 11th Gen i7-1165G7 laptop";
    users.lessuseless = {
      aspect = "lessuseless";  # References the lessuseless user aspect
    };
  };
}
```

This automatically generates `nixosConfigurations.tachi` by combining:
- `default` aspect (global defaults)
- `tachi` aspect (host-specific config)
- `lessuseless` aspect (user config)
- All included feature aspects

### User Configuration Pattern

User modules in `modules/lessuseless/` follow this structure:
- Each `.nix` file defines either `flake.modules.nixos.lessuseless`, `flake.modules.darwin.lessuseless`, or `flake.modules.homeManager.lessuseless`
- The main user module is `user.nix` which imports platform-specific configs
- `home.nix` defines home-manager configurations using helper function `lessuseless_at`

### Host Configuration Pattern

**Current (Den Pattern):**

Host aspects in `modules/aspects/[hostname].nix` define host-specific configuration and include feature aspects:
```nix
{ inputs, ... }:
{
  flake.aspects.tachi = {
    # Include feature aspects
    includes = { flake, ... }: with flake.aspects; [
      preservation
      impermanence
      disko
      niri-desktop
      kvm-intel
    ];

    # Host-specific configuration
    nixos = { pkgs, lib, config, ... }: {
      networking.hostName = "tachi";
      imports = [ ../hosts/tachi/preservation.nix ];
    };
  };
}
```

**Legacy (Traditional Pattern):**

Hosts in `modules/hosts/[hostname]/` can also import user and feature modules directly (deprecated):
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
# Rebuild current host (auto-detects hostname, defaults to switch)
# When inside the repo:
nix run .#os-rebuild
# When outside the repo (requires ~/.flake symlink):
nix run path:$HOME/.flake#os-rebuild

# Rebuild current host with specific action (boot, test, etc.)
nix run .#os-rebuild boot

# Rebuild specific host
nix run .#os-rebuild tachi switch

# Get help and see available hosts
nix run .#os-rebuild -- --help

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

## Ephemeral System Architecture

This configuration uses a **dual-layer ephemeral system** combining preservation (system-level) and impermanence (home-level):

### System Level: Preservation

**What it does:** Manages NixOS system state persistence in `/persist` using the [preservation](https://github.com/nix-community/preservation) module.

**Configuration:**
- Enabled via `preservation` aspect (`modules/aspects/features/preservation.nix`)
- Per-host rules in `modules/hosts/[hostname]/preservation.nix`
- Uses systemd-based initrd (required for preservation)
- Persists critical system files like `/var/lib/nixos`, `/etc/machine-id`, NetworkManager connections

**Example system-level preservation:**
```nix
preservation.preserveAt."/persist" = {
  directories = [
    { directory = "/var/lib/nixos"; inInitrd = true; }
    { directory = "/etc/NetworkManager/system-connections"; }
  ];
  files = [
    { file = "/etc/machine-id"; inInitrd = true; }
  ];
};
```

### Home Level: Impermanence

**What it does:** Manages user home directory persistence using [impermanence](https://github.com/nix-community/impermanence) home-manager module.

**Configuration:**
- Enabled via `impermanence` aspect (NixOS settings only - no `environment.persistence`)
- Per-user rules in `modules/lessuseless/impermanence.nix`
- Uses `home.persistence."/persist/home/lessuseless"` (NOT `environment.persistence`)
- Selectively persists user data, browser profiles, SSH keys, development tools

**Key aspects:**
- The `impermanence` aspect provides only NixOS-level support:
  - `/persist` filesystem mounting (`fileSystems."/persist".neededForBoot = true`)
  - Immutable users (`users.mutableUsers = false`)
  - FUSE support (`programs.fuse.userAllowOther = true`)
- The actual home-manager impermanence module is imported in user configs
- Each user controls their own persistence rules

**Example home-level impermanence:**
```nix
home.persistence."/persist/home/lessuseless" = {
  directories = [
    ".ssh"                    # SSH keys
    ".mozilla/firefox"        # Browser data
    ".config/gh"              # GitHub CLI auth
  ];
  files = [ ".bash_history" ];
  allowOther = true;
};
```

### Why This Design?

**System (preservation):** Handles early-boot requirements and system state that must exist before user sessions.

**Home (impermanence):** Gives users granular control over what persists in their home directory without needing system-level changes.

**IMPORTANT:** Do NOT import `inputs.impermanence.nixosModules.impermanence` in the impermanence aspect or feature modules. This would create unwanted `environment.persistence` options at the NixOS level. We only use the home-manager module (`inputs.impermanence.homeManagerModules.impermanence`) in user configurations.

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

**IMPORTANT**: Files must be **committed** (not just staged) before running `write-flake`. The flake-file auto-generation uses git to discover module files via import-tree. If you create new modules with `flake-file.inputs` declarations but don't commit them, those inputs won't appear in the generated flake.nix.

**Workflow**:
1. Create or modify modules with `flake-file.inputs` declarations
2. `git add` and `git commit` your changes
3. Run `nix run .#write-flake` to regenerate flake.nix
4. Commit the updated flake.nix and flake.lock

**Note**: The file header says "DO-NOT-EDIT" - modify module inputs instead.

## Creating a New Host

**Using Den Pattern (Recommended):**

1. Create host aspect: `modules/aspects/[hostname].nix`
   ```nix
   { inputs, ... }:
   {
     flake.aspects.[hostname] = {
       # Include feature aspects
       includes = { flake, ... }: with flake.aspects; [
         preservation
         impermanence
         # Add other feature aspects as needed
       ];

       # Host-specific configuration
       nixos = { pkgs, lib, config, ... }: {
         networking.hostName = "[hostname]";
         # Add host-specific config
       };
     };
   }
   ```

2. (Optional) Create host-specific configs: `modules/hosts/[hostname]/`
   - Add files like `preservation.nix` for host-specific persistence rules
   - Import from host aspect: `imports = [ ../hosts/[hostname]/preservation.nix ];`

3. Register host in `modules/flake/hosts.nix`:
   ```nix
   den.hosts.x86_64-linux.[hostname] = {
     description = "Description of the host";
     users.[username] = {
       aspect = "[username]";  # User aspect name
     };
   };
   ```

4. Commit changes and regenerate flake:
   ```bash
   git add . && git commit -m "Add [hostname] host"
   nix run .#write-flake
   git add flake.nix flake.lock && git commit -m "Regenerate flake"
   ```

5. Build and deploy:
   ```bash
   nix build .#nixosConfigurations.[hostname].config.system.build.toplevel
   sudo nix run .#os-rebuild -- [hostname] switch
   ```

**Legacy Pattern (Deprecated):**

1. Create directory: `modules/hosts/[hostname]/`
2. Add `configuration.nix` (NixOS) or `darwin-configuration.nix` (macOS)
3. Register in `modules/flake/osConfigurations.nix.old`

## Customizing for Your Own Setup

The original pattern was designed to be forked:

1. Rename `modules/vic/` → `modules/[yourname]/` (if it exists)
2. Update user aspect: `modules/aspects/lessuseless.nix` → `modules/aspects/[yourname].nix`
3. Update all references to `lessuseless` → `[yourname]` in:
   - User aspect file
   - User modules (`user.nix`, `home.nix`, etc.)
   - Host registrations in `modules/flake/hosts.nix`
   - Git/jujutsu user info
4. Update host aspects in `modules/aspects/` with your machines
5. Update `modules/flake/hosts.nix` with your host inventory
6. Update `flake.nix` description (or let dendritic regenerate it)

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
