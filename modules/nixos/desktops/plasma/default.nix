{ lib, config, ... }:
let
  cfg = config.cd.desktops.plasma;
in
{
  options.cd.desktops.plasma = {
    enable = lib.mkEnableOption "Enable Plasma";
    mobile.enable = lib.mkEnableOption "Enable Plasma Mobile";
  };

  config = lib.mkIf (cfg.enable || cfg.mobile.enable) {
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
