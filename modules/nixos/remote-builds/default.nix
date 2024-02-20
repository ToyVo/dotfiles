{ lib, config, pkgs, ... }:
let
  cfg = config.services.remote-builds;
in
{
  options.services.remote-builds = {
    server.enable = lib.mkEnableOption "Enable remote-builds server";
    client.enable = lib.mkEnableOption "Enable remote-builds client";
  };

  config = {
    users.users.nixremote = lib.mkIf cfg.server.enable {
      name = "nixremote";
      home = "/home/nixremote";
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        (lib.fileContents ../../../secrets/nixremote_ed25519.pub)
      ];
      isNormalUser = true;
    };

    home-manager.users.root.programs.ssh = lib.mkIf cfg.client.enable {
      enable = lib.mkDefault true;
      matchBlocks."builder" = {
        user = "nixremote";
        hostname = "10.1.0.3";
        identitiesOnly = true;
        identityFile = "${./nixremote_ed25519}";
      };
    };

    nix.settings.trusted-users = lib.mkIf cfg.server.enable [ "nixremote" ];
    nix.buildMachines = lib.mkIf cfg.client.enable [
      {
        hostName = "builder";
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = 1;
        speedFactor = 2;
        supportedFeatures = [ ];
        mandatoryFeatures = [ ];
      }
    ];
    nix.distributedBuilds = cfg.client.enable;
    nix.extraOptions = lib.mkIf cfg.client.enable ''
      builders-use-substitutes = true
    '';
  };
}
