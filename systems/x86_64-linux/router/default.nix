{ lib, pkgs, ... }: {
  hardware.cpu.intel.updateMicrocode = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  networking = {
    hostName = "router";
    networkmanager.enable = lib.mkForce false;
    domain = "diekvoss.net";
    useNetworkd = true;
    useDHCP = false;
    nameservers = [ "127.0.1.53" ];
    nat.enable = true;
    nat.externalInterface = "enp2s0";
    nat.internalInterfaces = [ "enp3s0" "cdiot" ];
    firewall = {
      enable = true;
      interfaces.enp3s0.allowedTCPPorts = [ 53 22 80 443 3000 ];
      interfaces.enp3s0.allowedUDPPorts = [ 53 67 68 ];
      interfaces.cdiot.allowedTCPPorts = [ 53 ];
      interfaces.cdiot.allowedUDPPorts = [ 53 67 68 ];
    };
  };
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usb_storage"
      "usbhid"
      "sd_mod"
      "sdhci_pci"
    ];
    kernelModules = [ "kvm-intel" ];
  };
  cd = {
    defaults.enable = true;
    users.toyvo.enable = true;
    fs.boot.enable = true;
    fs.btrfs.enable = true;
  };
  systemd.network = {
    enable = true;
    networks."10-wan0" = {
      matchConfig.Name = "enp2s0";
      networkConfig.DHCP = "ipv4";
      dhcpV4Config = {
        UseDNS = false;
      };
      linkConfig.RequiredForOnline = "routable";
    };
    networks."20-lan" = {
      matchConfig.Name = "enp3s0";
      address = [ "10.1.0.1/24" ];
      vlan = [ "cdiot" ];
      networkConfig = {
        DHCPServer = true;
        IPMasquerade = "ipv4";
        MulticastDNS = true;
      };
      dhcpServerConfig.DNS = [ "10.1.0.1" ];
      dhcpServerStaticLeases = [
        # Omada Controller
        {
          dhcpServerStaticLeaseConfig = {
            Address = "10.1.0.2";
            MACAddress = "10:27:f5:bd:04:97";
          };
        }
        # NCase
        {
          dhcpServerStaticLeaseConfig = {
            Address = "10.1.0.3";
            MACAddress = "70:85:c2:8a:53:5b";
          };
        }
        # Canon Printer
        {
          dhcpServerStaticLeaseConfig = {
            Address = "10.1.0.4";
            MACAddress = "c4:ac:59:a6:63:33";
          };
        }
        # HP Printer
        {
          dhcpServerStaticLeaseConfig = {
            Address = "10.1.0.5";
            MACAddress = "7c:4d:8f:91:d3:9f";
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
        IPMasquerade = "ipv4";
      };
      dhcpServerConfig.DNS = [ "10.1.0.1" ];
      linkConfig.RequiredForOnline = "no";
    };
  };
  services = {
    openssh.openFirewall = false;
    resolved = {
      enable = true;
      extraConfig = ''
        DNSStubListenerExtra=10.1.0.1
      '';
    };
    adguardhome = {
      enable = true;
      mutableSettings = false;
      settings.dns = {
        bind_hosts = [ "127.0.1.53" ];
        bootstrap_dns = [ "9.9.9.9" ];
      };
    };
    cfdyndns = {
      enable = true;
      email = "collin@diekvoss.com";
      records = [
        "*.diekvoss.net"
      ];
      apikeyFile = "${./cfapikey}";
      apiTokenFile = "${./cfapitoken}";
    };
    nginx = {
      enable = true;
      virtualHosts = {
        "omada.diekvoss.net" = {
          useACMEHost = "diekvoss.net";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://10.1.0.2:80";
            recommendedProxySettings = true;
          };
        };
        "nextcloud.diekvoss.net" = {
          useACMEHost = "diekvoss.net";
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://10.1.0.3:80";
            recommendedProxySettings = true;
          };
        };
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    certs = {
      "diekvoss.net" = {
        email = "collin@diekvoss.com";
        extraDomainNames = [ "*.diekvoss.net" ];
        dnsProvider = "cloudflare";
        credentialFiles = {
          "CF_API_EMAIL_FILE" = "${pkgs.writeText "cfemail" ''
            collin@diekvoss.com
          ''}";
          "CF_API_KEY_FILE" = "${./cfapikey}";
          "CF_DNS_API_TOKEN_FILE" = "${./cfapitoken}";
        };
      };
    };
  };
  users.users.nginx.extraGroups = [ "acme" ];
}
