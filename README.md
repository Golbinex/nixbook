# System
### Automatic ugprades + garbage collector
```
system.autoUpgrade.enable = true;
nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 7d";
};
```
### NTFY Notifications for required reboot after upgrade
Put `nixos-needsreboot.nix` to `/etc/nixos/`
```
systemd.timers."nixos-needsreboot" = {
  wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 18:00:00";
      Unit = "nixos-needsreboot.service";
    };
};

systemd.services."nixos-needsreboot" = {
  script = ''
    /run/current-system/sw/bin/nixos-needsreboot
    FILE=/var/run/reboot-required
    if test -f "$FILE"; then
      /run/current-system/sw/bin/curl -d "$(cat $FILE)" -u user:password https://ntfy.sh/channel
    fi
    rm $FILE
  '';
  serviceConfig = {
    Type = "oneshot";
    User = "root";
  };
};
environment.systemPackages = with pkgs; [
  (import ./nixos-needsreboot.nix)
];
```
### Decrypt system partition on boot via SSH
```
boot.kernelParams = ["ip=IP_ADDRESS::GATEWAY:NETMASK:HOSTNAME"];
boot.initrd.network = {
  enable = true;
  ssh = {
    enable = true;
    port = 22;
    hostKeys = [
      "/etc/secrets/initrd/ssh_host_rsa_key"
      "/etc/secrets/initrd/ssh_host_ed25519_key"
    ];
    authorizedKeys = [''
      YOUR_SSH_KEY
    ''];
  };
  postCommands = ''
    echo 'cryptsetup-askpass' >> /root/.profile
  '';
};
```
### Override package attributes (add entry to buildInputs)
```
let
  fdroidserver2 = pkgs.fdroidserver.overrideAttrs (finalAttrs: previousAttrs: {
    propagatedBuildInputs = previousAttrs.propagatedBuildInputs ++ [ pkgs.python3Packages.libvirt ];
  });
in
  environment.systemPackages = with pkgs; [
    fdroidserver2
  ];
```
# Network
### Whitelist IP address in firewall
```
networking.firewall = {
  extraCommands = "
    iptables -A nixos-fw --protocol all --src YOUR_IP_ADDRESS -j nixos-fw-accept
  ";
};
```
# ARM64 hardware
### Create bootable ARM64 ISO for Rockchip SBCs
Edit `configuration.nix`
```
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
```
Download `iso.nix`, then
```
nix-shell -p nixos-generators --run "nixos-generate --format iso --system aarch64-linux --configuration ./iso.nix -o result"
```
### HDMI output for Rockchip SBCs
```
boot.initrd.kernelModules = [ 
  # Rockchip modules
  "rockchip_rga"
  "rockchip_saradc"
  "rockchip_thermal"
  "rockchipdrm"

  # GPU/Display modules
  "analogix_dp"
  "cec"
  "drm"
  "drm_kms_helper"
  "dw_hdmi"
  "dw_mipi_dsi"
  "gpu_sched"
  "panel_edp"
  "panel_simple"
  "panthor"
  "pwm_bl"

  # USB / Type-C related modules
  "fusb302"
  "tcpm"
  "typec"

  # Misc. modules
  "cw2015_battery"
  "gpio_charger"
  "rtc_rk808"
];
```
### Load device tree
Find your board device tree in https://github.com/torvalds/linux/tree/master/arch/arm64/boot/dts and edit accordingly.
```
boot.kernelPackages = pkgs.linuxPackages_latest;
boot.loader.systemd-boot.extraFiles.${config.hardware.deviceTree.name} = "${config.hardware.deviceTree.package}/${config.hardware.deviceTree.name}";
hardware.deviceTree.enable = true;
hardware.deviceTree.name = "rockchip/rk3588-rock-5-itx.dtb";
hardware.deviceTree.filter = "*-rock-5-itx*.dtb";
boot.kernelParams = [ "dtb=/${config.hardware.deviceTree.name}" ];
```
