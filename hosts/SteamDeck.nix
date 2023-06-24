inputs:
let
  system = "x86_64-linux";
  user = "toyvo";
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    ../system/filesystem/btrfs.nix
    ../system/filesystem/efi.nix
    ../system/gnome.nix
    inputs.nixpkgs.nixosModules.notDetected
    inputs.nixvim.nixosModules.nixvim
    inputs.home-manager.nixosModules.home-manager
    inputs.jovian.nixosModules.jovian
    ({ lib, ... }: {
      boot = {
        initrd.availableKernelModules = [ "nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod" "sdhci_pci" ];
        initrd.kernelModules = [ ];
        kernelModules = [ "kvm-amd" ];
        extraModulePackages = [ ];
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        loader.efi.efiSysMountPoint = "/boot/efi";
      };
      swapDevices = [ ];
      hardware.cpu.amd.updateMicrocode = true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      networking.hostName = "steamdeck";
      jovian = {
        devices.steamdeck.enable = true;
        steam.enable = true;
        steam.autoStart = true;
        steam.user = user;
        steam.desktopSession = "gnome";
      };
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
