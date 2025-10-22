# Hardware Keys Setup Guide

## Setup Steps for Ledger Nano + Flipper Zero with SOPS

### 1. Apply the Configuration

First, rebuild with the new hardware-keys module:

```bash
sudo nixos-rebuild switch --flake .#tachi
```

This enables:
- GPG with smartcard support
- PC/SC daemon for hardware keys
- Ledger udev rules
- Hardware key management tools

### 2. Set Up Your Ledger Nano

#### Option A: Use Existing GPG Key on Ledger
If you already have a GPG key on your Ledger:

```bash
# Insert Ledger and unlock
gpg --card-status

# This should show your card and key info
# Note the key fingerprint (40-character hex string)
```

#### Option B: Generate New GPG Key on Ledger

```bash
# Install Ledger GPG app via Ledger Live first

# Generate key on device
gpg --card-edit
> admin
> generate
# Follow prompts, choose key size, expiration, name/email
```

### 3. Set Up Flipper Zero (Optional)

The Flipper Zero can store SSH/GPG keys. If you want to use it:

```bash
# Connect Flipper Zero
# Use qFlipper to manage keys

# Or use it as a U2F token for additional authentication
```

### 4. Get Your GPG Key Fingerprint

```bash
gpg --list-secret-keys --keyid-format LONG

# Output will show something like:
# sec   rsa4096/AABBCCDD11223344 2025-01-01 [SC]
#       AABBCCDD11223344EEFF00112233445566778899  <-- This is your fingerprint
# uid                 [ultimate] Your Name <you@example.com>
```

### 5. Update sops.yaml

Edit `modules/lessuseless/sops.yaml` and replace vic's key with yours:

```yaml
keys:
  - &lessuseless AABBCCDD11223344EEFF00112233445566778899  # Your GPG key fingerprint
creation_rules:
  - path_regex: ^.*$
    key_groups:
      - pgp:
          - *lessuseless
```

**IMPORTANT**: Use `pgp:` instead of `age:` in the creation rules!

### 6. Re-encrypt Your Secrets

If you have plaintext secrets to encrypt:

```bash
cd modules/lessuseless

# Edit secrets file (will use your hardware key to encrypt)
sops secrets.yaml

# When you save, SOPS will prompt for your hardware key PIN
```

To encrypt individual secret files:

```bash
# For binary secrets (SSH keys, tokens, etc.)
sops --encrypt secrets/my-secret > secrets/my-secret.encrypted
mv secrets/my-secret.encrypted secrets/my-secret
```

### 7. Test Decryption

```bash
# Test that you can decrypt with your hardware key
sops --decrypt secrets.yaml

# This should prompt for your hardware key PIN
# Then show the decrypted secrets
```

## Daily Usage

### Accessing Secrets

When NixOS rebuilds or home-manager activates:
1. You'll be prompted for your hardware key PIN
2. Enter PIN on Ledger Nano (or Flipper Zero)
3. SOPS decrypts secrets and places them in expected locations

### PIN Caching

The GPG agent caches your PIN for:
- Default: 1 hour
- Maximum: 2 hours

You can adjust these in `hardware-keys.nix`:
```nix
defaultCacheTtl = 3600;  # 1 hour in seconds
maxCacheTtl = 7200;      # 2 hours in seconds
```

### Editing Secrets

```bash
# Edit with hardware key
sops modules/lessuseless/secrets.yaml

# Add new secrets
sops --set '["new_api_key"] "your-secret-value"' secrets.yaml
```

## Security Benefits

✅ Private keys never leave hardware device
✅ PIN required for each operation (with caching)
✅ Physical device required to decrypt secrets
✅ Protected against malware/keyloggers
✅ Can't extract private keys even with root access

## Troubleshooting

### "No secret key" error
- Make sure hardware key is connected and unlocked
- Run `gpg --card-status` to verify detection
- Check `journalctl -u pcscd` for smartcard daemon logs

### "Operation cancelled"
- Verify you entered correct PIN on hardware device
- Check if device locked after too many attempts

### Ledger not detected
```bash
# Check USB connection
lsusb | grep Ledger

# Restart PC/SC daemon
sudo systemctl restart pcscd

# Check udev rules
ls /etc/udev/rules.d/*ledger*
```

### GPG agent issues
```bash
# Restart GPG agent
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent

# Check agent status
gpg-connect-agent 'getinfo version' /bye
```

## Alternative: age-plugin-yubikey

If you prefer using `age` format with hardware keys, you can also use `age-plugin-yubikey`:

```bash
# Generate age identity on hardware key
age-plugin-yubikey --generate

# Use with SOPS
sops --age <recipient> secrets.yaml
```

This is already included in the hardware-keys module.
