# NixOS and Home Manager configuration

Personal Nix configuration for two `x86_64-linux` hosts:

| Host | Purpose |
| --- | --- |
| `desktop` | Hyprland workstation with NVIDIA, gaming, Podman, and libvirt |
| `wsl` | NixOS-WSL environment with command-line tools and Podman |

## Repository layout

- `flake.nix` defines inputs, shared arguments, checks, and host outputs.
- `hosts/` contains host-specific hardware and feature settings.
- `system/` contains reusable NixOS modules.
- `home/` contains Home Manager modules and application configuration.

## Validate changes

Run the formatter and evaluate both complete host configurations before applying a change:

```sh
nix fmt
nix flake check --no-update-lock-file
nix eval --raw --no-update-lock-file \
  .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath
nix eval --raw --no-update-lock-file \
  .#nixosConfigurations.wsl.config.system.build.toplevel.drvPath
```

CI runs the same flake check and host evaluations for every push and pull request.

## Apply a configuration

From the repository root on the target host:

```sh
sudo nixos-rebuild switch --flake .#desktop
```

Use `.#wsl` instead when rebuilding the NixOS-WSL host.

## Upgrade notes

- Existing libvirt UEFI guests may still reference the pre-26.05 OVMF paths.
  Before starting an affected guest, run `virsh edit <domain>` and remove its
  automatically generated `<loader>` and `<nvram>` elements so libvirt can
  recreate them with the current paths.
- Confirm the desktop GPU is Turing/RTX 20-series or newer before applying the
  current NVIDIA `latest` driver. Maxwell, Pascal, and Volta hardware must use
  `config.boot.kernelPackages.nvidiaPackages.legacy_580` instead.

## Install the desktop

Lanzaboote needs signing keys from an already booted system, so a fresh install
uses systemd-boot for its first boot. Keep Secure Boot disabled in firmware and,
in `system/boot.nix`, temporarily change the existing
`boot.loader.systemd-boot.enable` value to `lib.mkForce true` and the existing
`boot.lanzaboote.enable` value to `false`.

After partitioning and mounting the target filesystem at `/mnt`, create a
root-only password hash outside the repository, install it, and perform the
bootstrap installation:

```sh
umask 077
nix shell nixpkgs#mkpasswd -c mkpasswd -m yescrypt > /tmp/joe-password-hash
sudo install -D -m 0600 -o root -g root \
  /tmp/joe-password-hash \
  /mnt/etc/nixos/secrets/joe-password-hash
sudo nixos-install --flake .#desktop --no-root-passwd
rm -f /tmp/joe-password-hash
```

Boot the installed system, create the signing keys, restore the two
`system/boot.nix` settings to their repository values, and switch to Lanzaboote:

```sh
sudo sbctl create-keys
sudo nixos-rebuild switch --flake .#desktop
sudo sbctl verify
```

Finally, put the firmware into Secure Boot setup mode, enroll the keys with
`sudo sbctl enroll-keys --microsoft`, and enable Secure Boot. Firmware workflows
vary, so keep recovery media available and confirm `sudo sbctl status` after
rebooting.

The password hash initializes the account without exposing a credential through
the Nix store. Later password changes are retained because NixOS uses mutable
users by default.

## Installation and security notes

- `hosts/desktop/disko.nix` targets `/dev/nvme0n1` and is destructive. Confirm the
  target disk on the destination machine before running Disko.
- No login password is stored in this public repository. Follow the installation
  step above so a fresh desktop is not created without a usable sudo account.
- Before applying this configuration to an existing desktop, place a root-owned,
  mode `0600` password hash at `/etc/nixos/secrets/joe-password-hash` and rotate
  the former temporary password with `passwd`. Desktop sudo requires
  authentication.
- Verify the authorized SSH key in `system/user.nix` before deploying to a new host.
- The stable and unstable package sets contain an exact EOL Electron exception
  required by Heroic, Joplin, and Proton Mail. Remove it as soon as those packages
  move to a supported release.

State-version values intentionally remain at the release used for the first
installation. Do not bump them as part of a routine dependency update.
