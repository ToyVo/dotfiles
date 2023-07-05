inputs:
let
  system = "aarch64-linux";
  user = "toyvo";
in inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    inputs.apple-silicon-support.nixosModules.apple-silicon-support
    inputs.nixpkgs.nixosModules.notDetected
    inputs.home-manager.nixosModules.home-manager
    inputs.nixvim.nixosModules.nixvim
    ../system/gnome.nix
    ../system/filesystem/btrfs.nix
    ../system/filesystem/boot.nix
    ({ lib, ... }: {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = false;
      hardware.asahi.peripheralFirmwareDirectory = /boot/asahi;
      networking.hostName = "MacBook-Pro-Nixos";
      boot.initrd.availableKernelModules = [ "usb_storage" "sdhci_pci" ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ ];
      boot.extraModulePackages = [ ];
      swapDevices = [ ];
      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
      powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs system; };
      home-manager.users.${user} = {
        home.username = user;
        home.homeDirectory = "/home/${user}";
        imports = [
          ../home
          ../home/git.nix
          ../home/gpg.nix
          ../home/ssh.nix
          ../home/starship.nix
          ../home/zsh.nix
        ];
      };
    })
  ];
}

