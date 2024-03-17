{ lib, config, pkgs, ... }:
let
  cfg = config.programs.helix;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nodePackages_latest.bash-language-server
      nodePackages_latest.typescript-language-server
      clang-tools
      vscode-langservers-extracted
      nil
      marksman
      taplo
      yaml-language-server
      lldb
    ];
    programs.helix = {
      settings = {
        theme = "catppuccin_frappe";
        editor = {
          line-number = "relative";
          bufferline = "always";
        };
      };
    };
  };
}
