{ pkgs, inputs, ... }: {
  profiles.defaults.enable = true;
  userPresets.toyvo.enable = true;
  homebrew.casks = [
    { name = "prusaslicer"; greedy = true; }
    { name = "google-chrome"; greedy = true; }
  ];
  environment.systemPackages = with pkgs; [
    openssl
  ];
}
