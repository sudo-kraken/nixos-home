{ username, pkgs, ... }:
{
  programs.zsh.enable = true;

  users.users.root.hashedPassword = "!";

  users.groups.${username} = { };
  users.users.${username} = {
    isNormalUser = true;
    initialPassword = "temp123";
    group = username;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAA7x2P/JL7+UKNSH+IpsE4b756Bv34ZLF3c4fDvhwSoL253Q3Tr1G9qI/zMnq536RCBvGpK0DtUXNlM/dUMyeLXLQG86PdhqGmHfOfmVU1OB/47sjpKa8uheb5B2RCjs8UkivZKvGYkLiAsio3V31+UXPaousu8Bxk7wpkIj8UnLUzVjg== ${username}"
    ];
  };
}
