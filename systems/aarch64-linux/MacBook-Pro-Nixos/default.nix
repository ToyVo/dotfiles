{ inputs, ... }:
let
  system = "aarch64-linux";
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    ({ lib, ... }: {
      imports = [
        inputs.apple-silicon-support.nixosModules.apple-silicon-support
        ../../../modules/nixos/cd-nixos
        ../../../modules/nixos/users/toyvo
      ];
      home-manager.extraSpecialArgs = { inherit inputs system; };
      nixpkgs.hostPlatform = lib.mkDefault system;
      powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
      networking.hostName = "MacBook-Pro-Nixos";
      boot = {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = false;
        initrd.availableKernelModules = [ "usb_storage" "sdhci_pci" ];
      };
      cd = {
        defaults.enable = true;
        users.toyvo.enable = true;
        fs.boot.enable = true;
        fs.btrfs.enable = true;
        desktops.gnome.enable = true;
      };
      hardware.asahi.peripheralFirmwareDirectory = ./firmware;
    })
  ];
}