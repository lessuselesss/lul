{ inputs, ... }:
{

  perSystem =
    { pkgs, lib, ... }:
    let

      same-system-oses =
        let
          has-same-system = _n: o: o.config.nixpkgs.hostPlatform.system == pkgs.system;
          all-oses = (inputs.self.nixosConfigurations or { }) // (inputs.self.darwinConfigurations or { });
        in
        lib.filterAttrs has-same-system all-oses;

      os-builder =
        name: os:
        let
          platform = os.config.nixpkgs.hostPlatform;
          darwin-rebuild = lib.getExe inputs.nix-darwin.packages.${platform.system}.darwin-rebuild;
          nixos-rebuild = lib.getExe pkgs.nixos-rebuild;
          flake-param = ''--flake "path:${inputs.self}#${name}" '';
        in
        pkgs.writeShellApplication {
          name = "${name}-os-rebuild";
          text = ''
            ${if platform.isDarwin then darwin-rebuild else nixos-rebuild} ${flake-param} --log-format internal-json -v "''${@}"
          '';
        };

      os-builders = lib.mapAttrs os-builder same-system-oses;

      os-rebuild = pkgs.writeShellApplication {
        name = "os-rebuild";
        text = ''
          export PATH="${
            pkgs.lib.makeBinPath (
              (lib.attrValues os-builders)
              ++ [
                pkgs.coreutils
                pkgs.nix-output-monitor
              ]
              ++ (lib.optionals pkgs.stdenv.isLinux [ pkgs.systemd pkgs.btrbk pkgs.util-linux ])

            )
          }"

          # Parse output format flag (environment variable or CLI flag)
          OUTPUT_FORMAT="''${OUTPUT_FORMAT:-nom}"  # default to nom, or use env var
          ARGS=()
          while [[ $# -gt 0 ]]; do
            case "$1" in
              -o|--output)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
              --output=*)
                OUTPUT_FORMAT="''${1#*=}"
                shift
                ;;
              -h|--help)
                echo "Usage: $0 [OPTIONS] [HOSTNAME] [${
                  if pkgs.stdenv.isDarwin then "DARWIN" else "NIXOS"
                }-REBUILD OPTIONS ...]"
                echo
                echo "Options:"
                echo "  -o, --output FORMAT   Build output format: nom (default), pinix, standard"
                echo "  -h, --help            Show this help message"
                echo
                echo "Default hostname: $(uname -n)"
                echo "Default ${if pkgs.stdenv.isDarwin then "darwin" else "nixos"}-rebuild options: switch"
                echo
                echo "Known hostnames on ${pkgs.system}:"
                echo "${lib.concatStringsSep "\n" (lib.attrNames same-system-oses)}"
                exit 0
                ;;
              *)
                ARGS+=("$1")
                shift
                ;;
            esac
          done
          set -- "''${ARGS[@]}"

          if test "file" = "$(type -t "''${1:-_}-os-rebuild")"; then
            hostname="$1"
            shift
          else
            hostname="$(uname -n)"
          fi

          if test "file" = "$(type -t "$hostname-os-rebuild")"; then
            # Check if this is a dry-run (non-destructive operation)
            IS_DRY_RUN=false
            for arg in "$@"; do
              case "$arg" in
                dry-build|dry-run|build-vm|build-vm-with-bootloader)
                  IS_DRY_RUN=true
                  break
                  ;;
              esac
            done

            # Check for uncommitted changes in flake repository
            if command -v git &> /dev/null && git -C "${inputs.self}" rev-parse --git-dir &> /dev/null; then
              if ! git -C "${inputs.self}" diff --quiet || ! git -C "${inputs.self}" diff --cached --quiet; then
                echo "⚠️  WARNING: Git tree has uncommitted changes"
                echo ""
                echo "📝 Modified files:"
                git -C "${inputs.self}" status --short | head -10
                echo ""
                echo "💡 Tip: Files must be committed for Nix to see them (especially new secrets)."
                echo "    Run: git add <files> && git commit -m 'description'"
                echo ""
              fi

              if git -C "${inputs.self}" ls-files --others --exclude-standard | grep -q .; then
                echo "⚠️  WARNING: Untracked files detected"
                echo ""
                echo "📝 Untracked files:"
                git -C "${inputs.self}" ls-files --others --exclude-standard | head -10
                echo ""
                echo "💡 Tip: New files must be committed before Nix can use them."
                echo "    Run: git add <files> && git commit -m 'description'"
                echo ""
              fi
            fi

            # Take a pre-rebuild snapshot on Linux systems with btrbk (skip for dry-runs)
            ${lib.optionalString pkgs.stdenv.isLinux ''
              if [ "$IS_DRY_RUN" = false ]; then
                # Detect filesystem type
                ROOT_FS=$(findmnt -n -o FSTYPE / 2>/dev/null || echo "unknown")

                if [ "$ROOT_FS" = "btrfs" ]; then
                  echo "💾 BTRFS detected"

                  # Check if btrbk is installed and configured
                  if command -v btrbk &> /dev/null; then
                    BTRBK_CONF="/etc/btrbk/time-machine.conf"

                    if [ -f "$BTRBK_CONF" ]; then
                      echo ""
                      echo "📋 Snapshot Configuration:"

                      # Parse and display subvolumes that will be snapshotted
                      SUBVOLS=$(grep -E '^\s+subvolume\s+' "$BTRBK_CONF" 2>/dev/null | awk '{print $2}' || echo "")
                      if [ -n "$SUBVOLS" ]; then
                        echo "   Subvolumes to snapshot:"
                        for subvol in $SUBVOLS; do
                          echo "   • /$subvol → /.snapshots/$subvol"
                        done
                      fi

                      echo ""
                      echo "  📸 Creating pre-rebuild snapshot..."

                      # Run btrbk to create snapshots
                      if btrbk -c "$BTRBK_CONF" run 2>&1 | grep -E '(snapshot|created|skipped)'; then
                        echo ""
                        echo "  🔍 Verifying snapshots..."

                        # Verify each snapshot was created
                        VERIFIED=0
                        FAILED=0
                        for subvol in $SUBVOLS; do
                          SNAPSHOT_DIR="/.snapshots/$subvol"
                          if [ -d "$SNAPSHOT_DIR" ]; then
                            LATEST=$(ls -t "$SNAPSHOT_DIR" 2>/dev/null | head -1)
                            if [ -n "$LATEST" ]; then
                              echo "     ✅ /$subvol: $LATEST"
                              VERIFIED=$((VERIFIED + 1))
                            else
                              echo "     ⚠️  /$subvol: no snapshots found"
                              FAILED=$((FAILED + 1))
                            fi
                          else
                            echo "     ⚠️  /$subvol: snapshot directory missing"
                            FAILED=$((FAILED + 1))
                          fi
                        done

                        echo ""
                        if [ "$VERIFIED" -gt 0 ]; then
                          echo "  ✅ Snapshot verification: $VERIFIED verified, $FAILED warnings"
                        else
                          echo "  ⚠️  No snapshots verified, continuing with rebuild..."
                        fi
                      else
                        echo "  ⚠️  Snapshot creation had issues, continuing with rebuild..."
                      fi
                    else
                      echo "  ℹ️  btrbk config not found at $BTRBK_CONF, skipping snapshot"
                    fi
                  else
                    echo "  ℹ️  btrbk not installed, skipping snapshot"
                  fi
                else
                  echo "❌ $ROOT_FS detected, snapshots not supported"
                fi
              else
                echo "🔍 Dry-run mode: Skipping pre-rebuild snapshot"
              fi
            ''}

            # Security checks (non-blocking)
            # Use printf with Unicode escape sequences for emoji at runtime
            CHECKING=$(printf '\u26AA')  # ⚪
            GREEN=$(printf '\U1F7E2')    # 🟢
            YELLOW=$(printf '\U1F7E1')   # 🟡
            RED=$(printf '\U1F534')      # 🔴

            # Check for leaked credentials in git history
            if command -v trufflehog &> /dev/null; then
              printf "%s Leaked Credentials" "$CHECKING"
              TRUFFLEHOG_OUTPUT=$(trufflehog git file://. --only-verified --no-update 2>/dev/null)
              COUNT=$(echo "$TRUFFLEHOG_OUTPUT" | grep -c "Found verified result" || echo 0)
              if [ "$COUNT" -gt 0 ]; then
                printf "\r\033[K%s Leaked Credentials - %s\n" "$RED" "$COUNT"
                echo "   → Run 'trufflehog git file://. --only-verified' for details"
              else
                printf "\r\033[K%s Leaked Credentials - 0\n" "$GREEN"
              fi
            fi

            # Check passwords against HIBP database
            if command -v gopass-hibp &> /dev/null && command -v gopass &> /dev/null; then
              printf "%s Password Breaches" "$CHECKING"
              HIBP_OUTPUT=$(gopass-hibp run 2>&1)
              HIBP_EXIT=$?
              COUNT=$(echo "$HIBP_OUTPUT" | grep -oP '\d+(?= passwords? (is|are) leaked)' | head -1 || echo 0)
              if [ "$HIBP_EXIT" -ne 0 ] && [ "$COUNT" -gt 0 ]; then
                printf "\r\033[K%s Password Breaches - %s\n" "$YELLOW" "$COUNT"
                echo "   → Run 'gopass-hibp run' for details"
              else
                printf "\r\033[K%s Password Breaches - 0\n" "$GREEN"
              fi
            fi

            # Apply output formatter
            case "$OUTPUT_FORMAT" in
              nom)
                "$hostname-os-rebuild" "''${@:-switch}" |& nom --json
                ;;
              pinix)
                if command -v pinix &> /dev/null; then
                  "$hostname-os-rebuild" "''${@:-switch}" |& pinix
                else
                  echo "⚠️  pinix not found, falling back to nom"
                  "$hostname-os-rebuild" "''${@:-switch}" |& nom --json
                fi
                ;;
              standard|plain)
                # Remove --log-format from the rebuild command for plain output
                # This requires modifying the host script behavior, so for now just pass through
                "$hostname-os-rebuild" "''${@:-switch}"
                ;;
              *)
                echo "Unknown output format: $OUTPUT_FORMAT"
                echo "Valid options: nom, pinix, standard"
                exit 1
                ;;
            esac
          else
            echo "No configuration found for host: $hostname"
            exit 1
          fi
        '';
      };

    in
    {
      packages.os-rebuild = os-rebuild;
    };
}
