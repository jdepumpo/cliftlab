{
  system.autoUpgrade = {
    enable = true;
    dates = "*-*-* 07:00:00";
    randomizedDelaySec = "1h";
    flake = "github:jdepumpo/cliftlab";
  };
}
