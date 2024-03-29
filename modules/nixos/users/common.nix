{ lib, pkgs, config, ... }:
let
  cfg = config.userPresets;
  homePath = if pkgs.stdenv.isDarwin then 
    "/Users" else 
    "/home";
  rootHomeDirectory = if pkgs.stdenv.isDarwin then 
    "/var/root" else 
    "/root";
  enableGui = config.profiles.gui.enable;
in
{
  options.userPresets.toyvo = {
    enable = lib.mkEnableOption "toyvo user";
    name = lib.mkOption {
      type = lib.types.str;
      default = "toyvo";
    };
  };

  config = {
    users.users = {
      ${cfg.toyvo.name} = lib.mkIf cfg.toyvo.enable {
        name = cfg.toyvo.name;
        description = "Collin Diekvoss";
        home = "${homePath}/${cfg.toyvo.name}";
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = [
          (lib.fileContents ./ykA_ed25519_sk.pub)
          (lib.fileContents ./ykC_ed25519_sk.pub)
        ];
      };
      root = {
        name = "root";
        home = rootHomeDirectory;
        shell = pkgs.zsh;
      };
    };
    home-manager.users = {
      ${cfg.toyvo.name} = lib.mkIf cfg.toyvo.enable {
        home.username = cfg.toyvo.name;
        home.homeDirectory = "${homePath}/${cfg.toyvo.name}";
        profiles.toyvo.enable = true;
        profiles.gui.enable = enableGui;
      };
      root = {
        home.username = "root";
        home.homeDirectory = rootHomeDirectory;
        profiles.defaults.enable = true;
      };
    };
  };
}
