# Browser Configuration

This directory contains supporting files for browser configuration.

## Structure

- `qutebrowser-profiles.nix` - Qutebrowser profile definitions
- `chromium-profiles.nix` - Chromium profile definitions

## Qutebrowser

**Persistence strategy**: Granular (sessions & cookies only)

**Persisted**:
- `.local/share/qutebrowser/sessions/` - Open tabs/windows
- `.local/share/qutebrowser/webengine/Cookies` - Cookies for staying logged in

**Ephemeral** (reset on reboot):
- Config (`~/.config/qutebrowser/`) - Managed by NixOS
- History - Fresh each boot for privacy
- Bookmarks - Use quickmarks in config instead
- Cache - Cleared on reboot

**Why?** Qutebrowser is your privacy-focused browser. You stay logged into sites you need, but browsing history and other data is ephemeral.

## Chromium

**Persistence strategy**: Full persistence

**Persisted**:
- `.config/chromium/` - Everything (profiles, extensions, history, cookies, etc.)

**Why?** Chromium is your convenience browser for sites that need full features. All data persists across reboots.

## Firefox

**Persistence strategy**: Full persistence (via main impermanence.nix)

**Persisted**:
- `.mozilla/firefox/` - Everything

## Adding more browsers

To add another browser:
1. Add config to `browsers.nix`
2. Add persistence rules to `impermanence.nix`
3. Document strategy in this README
