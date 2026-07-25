{
  guiEnabled,
  lib,
  pkgs-unstable,
  ...
}:
{
  services.gpg-agent = {
    enable = true;
    pinentry.package = lib.mkForce (
      if guiEnabled then pkgs-unstable.pinentry-qt else pkgs-unstable.pinentry-curses
    );
    enableExtraSocket = true;
  };
}
