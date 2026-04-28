{
  config,
  pkgs,
  lib,
  ...
}: let
  mkRoute = name: port: {
    routers.${name} = {
      rule = "Host(`${name}.clift.one`)";
      service = name;
      entryPoints = ["web"];
    };
    services.${name} = {
      loadBalancer.servers = [{url = "http://localhost:${toString port}";}];
    };
  };
in {
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

    transmission = {
      enable = true;
      vpn.enable = true;
    };

    sabnzbd = {
      enable = true;
      vpn.enable = true;
    };
  };

  services.traefik.dynamicConfigOptions.http = lib.foldl lib.recursiveUpdate {} [
    (mkRoute "jellyfin" 8096)
    (mkRoute "sonarr" 8989)
    (mkRoute "radarr" 7878)
    (mkRoute "lidarr" 8686)
    (mkRoute "prowlarr" 9696)
    (mkRoute "bazarr" 6767)
    (mkRoute "transmission" 9091)
    (mkRoute "sabnzbd" 8085)
  ];

  # Intel QSV / VA-API hardware transcoding for Jellyfin (M710q iGPU)
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };
}
