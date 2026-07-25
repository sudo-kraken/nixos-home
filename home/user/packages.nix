{
  pkgs,
  pkgs-unstable,
  lib,
  guiEnabled,
  ...
}:
let
  # Packages CLI - no GUI
  cliPackages = with pkgs-unstable; [
    # dev
    vim
    strace
    curl
    gcc
    gnumake
    python3
    go
    delve # go debugger
    rustup
    lldb # rust debugger
    protobuf
    bpftrace
    yq # command-line YAML, JSON, XML, CSV, TOML
    eza # a modern, maintained replacement for ls
    bat # enhanced cat command
    hyperfine # benchmarking tool
    btop # A monitor of resources
    ripgrep
    kind
    cloud-provider-kind

    # infra
    tio # serial device I/O tool
    tcpdump
    nmap
    iperf
    kubectl
    kubernetes-helm
    fluxcd
    stern
    packer
    pulumi
    postgresql
    sqlite
    doggo # command-line DNS client
    restic
    rsync
    rclone
    go-task
    rdap # Registry Data Access Protocol
    zizmor # Tool for finding security issues in GitHub Actions setups
    wireguard-tools # wireguard vpn

    # misc
    unzip
    gnutar
    pciutils # lspci
    marp-cli # presentation with plain Markdown
  ];

  guiPackages =
    (with pkgs; [
      # DE (Desktop Environment) - stable
      hyprpicker # color picker
      hyprcursor # cursor
      hyprlock # screen locking utility
      hypridle # idle daemon
      hyprpaper # wallpaper utility
      hyprshot # screenshot utility
      # hyprland-qtutils
      wl-clipboard # copy/paste utilities for Wayland
      wl-clip-persist # Keep Wayland clipboard even after programs close
      rofi # Keystroke launcher
      nemo # file manager
      engrampa # archive manager
      yad # gui dialog (used as shortcut reminder)
      nerd-fonts.jetbrains-mono # nerdfonts font
      qt6.qtwayland
      qt5.qtwayland
    ])
    ++ (with pkgs-unstable; [
      # dev tools
      hoppscotch # open-source alternative to Postman
      wireshark

      # misc
      brightnessctl # controlling backlight
      playerctl # media player command-line controller
      gpu-screen-recorder-gtk
      deskflow # keyboard and mouse sharing app

      # app
      protonmail-desktop # email client for proton
      proton-vpn # vpn client for proton
      keepassxc # password manager
      (discord.override { withVencord = true; }) # social media
      slack # team communication
      zoom-us # video conferencing
      joplin-desktop # note-taking app
      karere # messaging app
      deckmaster # stream deck software
      jellyfin-desktop # media player
      stremio-linux-shell # media streaming
      mpv # video player
      imv # image viewer
      qbittorrent # torrent
      telegram-desktop # messaging app

      # office tool
      libreoffice-qt
      hunspell
      hunspellDicts.fr-moderne
      hunspellDicts.en_US
      gimp # Image Manipulation Program
    ]);
in
{
  home.packages = cliPackages ++ lib.optionals guiEnabled guiPackages;
}
