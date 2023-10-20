{ lib, config, ... }:
let
  cfg = config.cd;
in
{
  options.cd.desktops.plasma = {
    enable = lib.mkEnableOption "Enable Plasma";
    mobile.enable = lib.mkEnableOption "Enable Plasma Mobile";
  };

  config = lib.mkIf (cfg.desktops.plasma.enable || cfg.desktops.plasma.mobile.enable) {
    services.xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = cfg.enable;
      desktopManager.plasma5.mobile.enable = cfg.mobile.enable;
      libinput.enable = true;
    };
    programs.gnupg.agent.pinentryFlavor = "qt";
    cd.packages.gui.enable = true;
  };
}