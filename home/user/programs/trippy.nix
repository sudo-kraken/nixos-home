{ pkgs-unstable, ... }:
{
  programs.trippy = {
    enable = true;
    package = pkgs-unstable.trippy;
    forceUserConfig = false;
    settings = {
      tui = {
        tui-locale = "en";
      };
      strategy = {
        addr-family = "system";
      };
    };
  };

  # trippy does not support native unprivileged mode https://github.com/fujiapple852/trippy/issues/741
  # therefore we have to use the security wrapper
  programs.zsh.shellAliases = {
    trip = "/run/wrappers/bin/trip";
  };
}
