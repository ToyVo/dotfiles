inputs:
let
  system = "x86_64-linux";
  user = "toyvo";
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs; };
  modules = [
    inputs.nixpkgs.nixosModules.notDetected
    inputs.nixvim.nixosModules.nixvim
    inputs.home-manager.nixosModules.home-manager
    ../system/filesystem/btrfs.nix
    ../system/filesystem/efi.nix
    ../system/nixos.nix
    ({ lib, ... }: {
      networking.networkmanager.enable = lib.mkForce false;
      boot = {
        initrd.availableKernelModules = [
          "xhci_pci"
          "ahci"
          "nvme"
          "usb_storage"
          "usbhid"
          "sd_mod"
          "sdhci_pci"
        ];
        initrd.kernelModules = [ ];
        kernelModules = [ "kvm-intel" ];
        extraModulePackages = [ ];
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        loader.efi.efiSysMountPoint = "/boot/efi";
      };
      swapDevices = [ ];
      powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
      hardware.cpu.intel.updateMicrocode = true;
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      systemd.network = {
        enable = true;

        networks."10-wan0" = {
          matchConfig.Name = "enp2s0";
          networkConfig = {
            IPv6AcceptRA = true;
            IPForward = "yes";
            DHCP = "yes";
          };
          dhcpV4Config = {
            UseDNS = false;
          };
          dhcpV6Config = {
            UseDNS = false;
            PrefixDelegationHint = "::56";
          };
          linkConfig.RequiredForOnline = "routable";
        };

        networks."20-lan" = {
          matchConfig.Name = "enp3s0";
          address = [ "10.1.0.1/24" ];
          vlan = [ "cdiot" ];
          networkConfig = {
            DHCPServer = true;
            IPMasquerade = "both";
            IPv6SendRA = true;
            DHCPPrefixDelegation = true;
          };
          dhcpServerConfig.DNS = ["10.1.0.1"];
          dhcpServerStaticLeases = [
            # Omada Controller
            {
              dhcpServerStaticLeaseConfig = {
                Address = "10.1.0.2";
                MACAddress = "10:27:f5:bd:04:97";
              };
            }
            # Canon Printer
            {
              dhcpServerStaticLeaseConfig = {
                Address = "10.1.0.3";
                MACAddress = "c4:ac:59:a6:63:33";
              };
            }
            # NCase
            {
              dhcpServerStaticLeaseConfig = {
                Address = "10.1.0.4";
                MACAddress = "70:85:c2:8a:53:5b";
              };
            }
          ];
          linkConfig.RequiredForOnline = "no";
        };

        netdevs."25-cdiot" = {
          netdevConfig = {
            Name = "cdiot";
            Kind = "vlan";
          };
          vlanConfig.Id = 20;
        };
        networks."25-cdiot" = {
          matchConfig.Name = "cdiot";
          address = [ "10.1.20.1/24" ];
          networkConfig = {
            DHCPServer = true;
            IPMasquerade = "both";
          };
          dhcpServerConfig.DNS = ["10.1.0.1"];
          linkConfig.RequiredForOnline = "no";
        };
      };
      networking = {
        hostName = "router";
        domain = "diekvoss.net";
        useNetworkd = true;
        useDHCP = false;
        nameservers = [ "127.0.1.53" ];
        nat.enable = true;
        nat.externalInterface = "enp2s0";
        nat.internalInterfaces = [ "enp3s0" "cdiot" ];
        firewall = {
          enable = true;
          interfaces.enp3s0.allowedTCPPorts = [ 53 22 3000 ];
          interfaces.enp3s0.allowedUDPPorts = [ 53 67 68 ];
          interfaces.cdiot.allowedTCPPorts = [ 53 ];
          interfaces.cdiot.allowedUDPPorts = [ 53 67 68 ];
        };
      };
      services.openssh.openFirewall = false;
      services.resolved.enable = true;
      services.resolved.extraConfig = ''
        DNSStubListenerExtra=10.1.0.1
      '';
      services.adguardhome = {
        enable = true;
        settings.dns.bind_hosts = ["127.0.1.53"];
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
