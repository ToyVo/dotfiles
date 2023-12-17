{ lib, pkgs, system, inputs, ... }: {
  hardware.cpu.amd.updateMicrocode = true;
  hardware.bluetooth.enable = true;
  networking.hostName = "steamdeck-nixos";
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
    kernelModules = [ "kvm-amd" ];
  };
  cd = {
    defaults.enable = true;
    users.toyvo.enable = true;
    fs.boot.enable = true;
    fs.btrfs.enable = true;
    desktops.gnome.enable = true;
    # remote-builds.client.enable = true;
  };
  fileSystems."/mnt/POOL" = {
    device = "/dev/disk/by-label/POOL";
    fsType = "btrfs";
    options = [ "nofail" "noatime" "lazytime" "compress-force=zstd" "space_cache=v2" "autodefrag" "ssd_spread" ];
  };
  jovian = {
    devices.steamdeck.enable = true;
    steam.enable = true;
    steam.autoStart = true;
    steam.user = "toyvo";
    steam.desktopSession = "gnome";
  };
  environment.systemPackages = with pkgs; [
    steam
    discord
    inputs.nixpkgs-unstable.legacyPackages.${system}.r2modman
    obs-studio
    obs-studio-plugins.obs-gstreamer
  ];
  services.xserver.displayManager.gdm.enable = lib.mkForce false;
}
