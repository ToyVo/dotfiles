{nixpkgs, nixpkgs-unstable, home-manager}: let
  system = "x86_64-linux";
  user = "deck";
  pkgs = nixpkgs.legacyPackages.${system};
  pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
in home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [ 
    ({...}:{
      home.username = user;
      home.homeDirectory = "/home/${user}";
    })
    ../home/home-common.nix
    ../home/home-linux.nix
    ../home/neovim.nix
    ../home/alacritty.nix
    ../home/kitty.nix
    ../home/git.nix
    ../home/gpg-common.nix
    ../home/gpg-linux.nix
    ../home/ssh.nix
    ../home/starship.nix
    ../home/zsh.nix
    ../home/desktop-files.nix
  ];
  extraSpecialArgs = {
    inherit pkgs-unstable;
  };
}
