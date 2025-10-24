## Immediate Tasks (tachi system blocked)

-[ ] **URGENT: Fix sudo access**
    - Current: Can't use sudo (empty password, mutableUsers=false)
    - Solution: Reboot and test password "temp123" with new config
    - Then rebuild to apply all changes

-[ ] **Rebuild system to apply changes**
    - Run: `sudo nix run .#os-rebuild -- switch` (after sudo fixed)
    - Applies: time-machine service, fixed impermanence, Ctrl key fix

-[ ] **Fix home-manager conflicts after rebuild**
    ```bash
    rm /home/lessuseless/.config/git/ignore
    rm /home/lessuseless/.config/nvim
    sudo systemctl start home-manager-lessuseless.service
    ```

-[ ] **Fix system UID/GID warnings**
    - Warning: `/var/lib/nixos` not persisted - system users need fixed UIDs/GIDs
    - Add to preservation module or set explicit UIDs for: colord, nm-iodine, nscd, rtkit, systemd-oom

-[ ] **Setup git authentication for pushing**
    - Use gh CLI to authenticate
    - Or setup SSH keys for GitHub

## Completed ✅

-[x] Create time-machine backup service (httm + btrbk)
-[x] Fix impermanence (use home.persistence instead of environment.persistence)
-[x] Add session persistence (.mozilla, .local/share/keyrings, etc.)
-[x] Remove macos-keys from tachi (restore Ctrl key)
-[x] Add fish abbreviations (nos, nob, not, ht, hts, etc.)
-[x] Create modules/lessuseless/services/ directory structure

## Future Integrations

-[ ] **Co-workspace for autonomous agents**
    - Create `/co-workspace/` - shared filesystem for agent collaboration
    - Structure:
      - `/co-workspace/shared/` - Shared context/state between agents
      - `/co-workspace/claude/` - Claude Code workspace
      - `/co-workspace/projects/` - Active projects (could host nixos-config)
      - `/co-workspace/outputs/` - Agent-generated artifacts
    - Benefits: Clean separation, clear semantic purpose, multi-agent coordination
    - Alternative: Keep `~/.flake` but clone from GitHub to local disk for speed

-[ ] External Project (WIP/Todo)
    -[ ] Niri-keymaps (app invokable by hotkey that discovers + shows the focused programs keymaps/shortcuts)
    -[ ] Niri-hints [integrate hints into niri + wayland)
    -[ ] Niri-super-productivity (task-driven contextual workspaces filtering (off-task, focus breaking content is moved to the right-most in niri's wm)


-[ ] Layers:
    -[ ] Niri (look at https://github.com/Vortriz/awesome-niri for integrations)
    -[ ] Hints (Multiple DE Environments + Niri)

-[ ] Modules:
    -[ ] Typix
    -[x] httm (completed - in time-machine service)

-[ ] Nix Apps
    -[ ] opsec (hardware key scripts/workflows)
    -[ ] backups /w live environment credential restore/rotation via flake-rite (PR is probably necessary)
    -[ ] time-machine-backup (manual backup runner via nix run)
