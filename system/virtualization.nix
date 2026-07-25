{ pkgs, username, ... }:
{
  users.users.${username} = {
    extraGroups = [ "libvirtd" ];
  };

  environment.systemPackages = with pkgs; [
    qemu
    spice
    spice-gtk
    spice-protocol
    virt-manager
    virt-viewer
    win-spice
    virtio-win
  ];

  virtualisation = {
    spiceUSBRedirection.enable = true;

    libvirtd = {
      enable = true;

      qemu.swtpm.enable = true;
    };
  };
}
