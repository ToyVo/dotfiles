inputs:
let
  system = "aarch64-linux";
in inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    inputs.nixos-hardware.nixosModules.pine64-pinebook-pro
    inputs.home-manager.nixosModules.home-manager
    inputs.nixvim.nixosModules.nixvim
    ../system/nixos.nix
    ../home/toyvo.nix
    ({ lib, ... }: {
      boot.loader.grub.enable = false;
      boot.loader.generic-extlinux-compatible.enable = true;
      networking.hostName = "PineBook-Pro";
      networking.useDHCP = lib.mkDefault true;
      nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs system; };
      cdcfg.users.toyvo.enable = true;
      cdcfg.fs.sd.enable = true;
    })
  ];
}
