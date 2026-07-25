{ pkgs, ... }:
{
  home.packages = with pkgs; [
    coreutils
    socat
  ];

  systemd.user.services.ssh-agent-proxy = {
    Unit = {
      Description = "Windows SSH agent proxy";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStartPre = [
        "${pkgs.coreutils}/bin/mkdir -p /mnt/wsl"
        "${pkgs.coreutils}/bin/rm -f /mnt/wsl/ssh-agent.sock"
      ];
      ExecStart = "${pkgs.writeShellScript "ssh-agent-proxy" ''
        set -e

        # Query the Windows username without the discontinued wslu package.
        WIN_USER="$(
          /mnt/c/Windows/System32/cmd.exe /D /C "echo %USERNAME%" 2>/dev/null \
            | ${pkgs.coreutils}/bin/tr -d '\r'
        )"
        if [ -z "$WIN_USER" ]; then
          WIN_USER="$USER"
        fi

        NPIPE_PATHS=(
          "/mnt/c/Users/$WIN_USER/AppData/Local/Microsoft/WinGet/Links/npiperelay.exe"
          "/mnt/c/ProgramData/chocolatey/bin/npiperelay.exe"
          "/mnt/c/Users/$WIN_USER/.wsl/npiperelay.exe"
        )

        NPIPE_PATH=""
        for path in "''${NPIPE_PATHS[@]}"; do
          if [ -f "$path" ]; then
            NPIPE_PATH="$path"
            break
          fi
        done

        if [ -z "$NPIPE_PATH" ]; then
          echo "npiperelay.exe not found in expected locations" >&2
          exit 1
        fi

        exec ${pkgs.socat}/bin/socat UNIX-LISTEN:/mnt/wsl/ssh-agent.sock,fork,mode=600 \
          EXEC:"$NPIPE_PATH -ei -s //./pipe/openssh-ssh-agent",nofork
      ''}";
      Type = "simple";
      Restart = "always";
      RestartSec = "5";
    };
  };

  home.sessionVariables = {
    SSH_AUTH_SOCK = "/mnt/wsl/ssh-agent.sock";
  };
}
