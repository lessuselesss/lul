{ ... }:
{
  flake.modules.homeManager.lessuseless =
    { pkgs, config, ... }:
    {
      home.packages = with pkgs; [
        gopass
        age # Ensure age is available
        gopass-jsonapi # For browser integration
        gopass-summon-provider # For summon integration
        gopass-hibp # Check passwords against Have I Been Pwned
      ];

      # Initialize gopass to use age and store in secrets directory
      # The age key from SOPS can be reused
      home.activation.gopassAgeSetup = config.lib.dag.entryAfter [ "writeBoundary" ] ''
                GOPASS_CONFIG="$HOME/.config/gopass/config.yml"
                GOPASS_DIR="$HOME/.config/lul/modules/lessuseless/secrets/gopass"

                # Only run if gopass is not already initialized
                if [ ! -f "$GOPASS_CONFIG" ]; then
                  $DRY_RUN_CMD mkdir -p "$HOME/.config/gopass"
                  $DRY_RUN_CMD mkdir -p "$GOPASS_DIR"

                  # Create initial config pointing to age
                  $DRY_RUN_CMD cat > "$GOPASS_CONFIG" <<EOF
        autoclip: true
        autoimport: false
        cliptimeout: 45
        exportkeys: false
        nocolor: false
        notifications: true
        parsing: true
        path: $GOPASS_DIR
        safecontent: false
        EOF

                  echo "Gopass configuration created. Initialize with:"
                  echo "  gopass init --crypto age --storage gitfs"
                  echo "  (Use your age key from ~/.config/sops/age/keys.txt)"
                  echo ""
                  echo "After initialization, configure browser integration with:"
                  echo "  gopass-jsonapi configure"
                fi
      '';

      # Optional: Set up shell completions
      programs.bash.initExtra = ''
        source <(gopass completion bash)
      '';

      programs.zsh.initExtra = ''
        source <(gopass completion zsh)
      '';

      programs.fish.shellInit = ''
        gopass completion fish | source
      '';
    };
}
