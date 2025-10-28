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
          nom = lib.getExe pkgs.nix-output-monitor;
          flake-param = ''--flake "path:${inputs.self}#${name}" '';
        in
        pkgs.writeShellApplication {
          name = "${name}-os-rebuild";
          text = ''
            ${if platform.isDarwin then darwin-rebuild else nixos-rebuild} ${flake-param} --log-format internal-json -v "''${@}" |& ${nom} --json
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
              ]
              ++ (lib.optionals pkgs.stdenv.isLinux [ pkgs.systemd pkgs.btrbk ])

            )
          }"

          if [ "-h" = "''${1:-}" ] || [ "--help" = "''${1:-}" ]; then
            echo Usage: "$0" [HOSTNAME] [${
              if pkgs.stdenv.isDarwin then "DARWIN" else "NIXOS"
            }-REBUILD OPTIONS ...]
            echo
            echo Default hostname: "$(uname -n)"
            echo Default ${if pkgs.stdenv.isDarwin then "darwin" else "nixos"}-rebuild options: switch
            echo
            echo Known hostnames on ${pkgs.system}:
            echo "${lib.concatStringsSep "\n" (lib.attrNames same-system-oses)}"
            exit 0
          fi

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

            # Check for leaked credentials in git history
            if command -v trufflehog &> /dev/null; then
              printf "⚪ Leaked Credentials"
              TRUFFLEHOG_OUTPUT=$(trufflehog git file://. --only-verified --no-update 2>/dev/null)
              COUNT=$(echo "$TRUFFLEHOG_OUTPUT" | grep -c "Found verified result" || echo 0)
              if [ "$COUNT" -gt 0 ]; then
                printf "\r\033[K🔴 Leaked Credentials - $COUNT\n"
                echo "   → Run 'trufflehog git file://. --only-verified' for details"
              else
                printf "\r\033[K🟢 Leaked Credentials - 0\n"
              fi
            fi

            # Check passwords against HIBP database
            if command -v gopass-hibp &> /dev/null && command -v gopass &> /dev/null; then
              printf "⚪ Password Breaches"
              HIBP_OUTPUT=$(gopass-hibp run 2>&1)
              HIBP_EXIT=$?
              COUNT=$(echo "$HIBP_OUTPUT" | grep -oP '\d+(?= passwords? (is|are) leaked)' | head -1 || echo 0)
              if [ "$HIBP_EXIT" -ne 0 ] && [ "$COUNT" -gt 0 ]; then
                printf "\r\033[K🟡 Password Breaches - $COUNT\n"
                echo "   → Run 'gopass-hibp run' for details"
              else
                printf "\r\033[K🟢 Password Breaches - 0\n"
              fi
            fi

            "$hostname-os-rebuild" "''${@:-switch}"
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
