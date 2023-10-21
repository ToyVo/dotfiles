{ pkgs, ... }: {
  cd.defaults.enable = true;
  cd.users.toyvo = {
    enable = true;
    name = "CollinDie";
    extraHomeManagerModules = [
      ./secrets.nix
      {
        programs = {
          ssh.matchBlocks."github-emu" = {
            hostname = "github.com";
            identitiesOnly = true;
            identityFile = "${./ssh_emu.pub}";
            extraOptions.AddKeysToAgent = "yes";
          };
          gpg.publicKeys = [{
            source = ./gpg_emu.pub;
            trust = 5;
          }];
          zsh.profileExtra = ''
            export PATH="$VOLTA_HOME/bin:$PATH"
          '';
        };
        home.packages = with pkgs;
          [
            awscli2
            volta
          ];
        home.sessionVariables = {
          VOLTA_HOME = "$HOME/.volta";
          NODE_ENV = "development";
          RUN_ENV = "local";
        };
      }
    ];
  };
  homebrew = {
    brews = [
      "mongosh"
      "mongodb-community@4.4"
      "mongodb-community-shell@4.4"
      "mongodb-database-tools"
    ];
    casks = [
      { name = "docker"; greedy = true; }
      { name = "mongodb-compass"; greedy = true; }
      { name = "slack"; greedy = true; }
    ];
    taps = [
      "mongodb/brew"
    ];
    masApps = {
      "Yubico Authenticator" = 1497506650;
    };
  };
}
