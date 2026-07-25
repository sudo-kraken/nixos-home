{
  username,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../../system/container.nix
    ../../system/internationalization.nix
    ../../system/nixsettings.nix
    ../../system/security.nix
    ../../system/ssh.nix
    ../../system/user.nix
    ../../home
  ];

  wsl.enable = true;
  wsl.defaultUser = username;

  # NixOS-WSL disables this entry while WSL owns the file, but the NixOS
  # AppArmor module still evaluates its source when building the system closure.
  environment.etc."resolv.conf".source = "/etc/resolv.conf";

  # fix for vscode remote : https://nix-community.github.io/NixOS-WSL/how-to/vscode.html
  environment.systemPackages = [
    pkgs.wget
  ];

  programs.nix-ld.enable = true;
}
