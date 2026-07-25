{ pkgs, ... }:
let
  sddmWaylandSession = pkgs.writeShellScript "sddm-wayland-session" ''
    # Expose the local agent to GUI apps without overriding forwarded agents.
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent"
    exec ${pkgs.kdePackages.sddm}/share/sddm/scripts/wayland-session "$@"
  '';
in
{
  programs.hyprland.enable = true;

  services.displayManager = {
    defaultSession = "hyprland";
    sddm = {
      enable = true;
      autoNumlock = true;
      # needed for sddm theme (qt6 sddm version)
      package = pkgs.kdePackages.sddm;
      settings.Wayland.SessionCommand = toString sddmWaylandSession;
      theme = "sddm-astronaut-theme";
      enableHidpi = true;
      wayland.enable = true;
      extraPackages = with pkgs; [
        sddm-astronaut
      ];
    };
  };

  environment.systemPackages = [
    (pkgs.sddm-astronaut.override {
      themeConfig = {
        AccentColor = "#B2D0E2";
        FormPosition = "left";
        ForceHideCompletePassword = true;
      };
    })
  ];
}
