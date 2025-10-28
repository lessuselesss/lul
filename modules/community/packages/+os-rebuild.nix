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
              ++ (lib.optionals pkgs.stdenv.isLinux [ pkgs.systemd pkgs.btrbk ])

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

            # Take a pre-rebuild snapshot on Linux systems with btrbk
            ${lib.optionalString pkgs.stdenv.isLinux ''
              if command -v btrbk &> /dev/null && systemctl is-active --quiet btrbk-time-machine.service 2>/dev/null || true; then
                echo "📸 Creating pre-rebuild snapshot..."
                systemctl start btrbk-time-machine.service || echo "⚠️  Snapshot failed, continuing with rebuild..."
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
