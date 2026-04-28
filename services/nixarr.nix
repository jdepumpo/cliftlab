{
  config,
  pkgs,
  ...
}: {
  sops.secrets."mullvad-wg" = {
    format = "binary";
    sopsFile = ./../secrets/mullvad-wg.conf;
  };

  nixarr = {
    enable = true;
    mediaDir = "/nix/persist/media";
    stateDir = "/nix/persist/nixarr";

    vpn = {
      enable = true;
      wgConf = config.sops.secrets."mullvad-wg".path;
    };

    jellyfin.enable = true;

    prowlarr.enable = true;
    sonarr.enable = true;
    radarr.enable = true;
    lidarr.enable = true;
    bazarr.enable = true;

    qbittorrent = {
      enable = true;
      vpn.enable = true;
    };

    sabnzbd = {
      enable = true;
      vpn.enable = true;
    };
  };

  # Intel QSV / VA-API hardware transcoding for Jellyfin (M710q iGPU)
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
}
