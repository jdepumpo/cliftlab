{
  config,
  pkgs,
  lib,
  ...
}: let
  mkRoute = name: port: protected: {
    routers.${name} =
      {
        rule = "Host(`${name}.clift.one`)";
        service = name;
        entryPoints = ["web"];
      }
      // lib.optionalAttrs protected {middlewares = ["authelia"];};
    routers."${name}-secure" =
      {
        rule = "Host(`${name}.clift.one`)";
        service = name;
        entryPoints = ["websecure"];
        tls.certResolver = "cloudflare";
      }
      // lib.optionalAttrs protected {middlewares = ["authelia"];};
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
    {
      middlewares.authelia.forwardAuth = {
        address = "http://127.0.0.1:9092/api/authz/forward-auth";
        trustForwardHeader = true;
        authResponseHeaders = ["Remote-User" "Remote-Groups" "Remote-Email" "Remote-Name"];
      };
      routers.authelia = {
        rule = "Host(`auth.clift.one`)";
        service = "authelia";
        entryPoints = ["web"];
      };
      routers."authelia-secure" = {
        rule = "Host(`auth.clift.one`)";
        service = "authelia";
        entryPoints = ["websecure"];
        tls.certResolver = "cloudflare";
      };
      services.authelia.loadBalancer.servers = [{url = "http://127.0.0.1:9092";}];
    }
    {
      # OpenCloud always uses HTTPS internally — skip TLS verification since it's a self-signed cert
      serversTransports.opencloud.insecureSkipVerify = true;
      routers.cloud = {
        rule = "Host(`cloud.clift.one`)";
        service = "cloud";
        entryPoints = ["web"];
      };
      routers."cloud-secure" = {
        rule = "Host(`cloud.clift.one`)";
        service = "cloud";
        entryPoints = ["websecure"];
        tls.certResolver = "cloudflare";
      };
      services.cloud.loadBalancer = {
        servers = [{url = "https://localhost:9200";}];
        serversTransport = "opencloud";
      };
    }
    (mkRoute "ha" 8123 false)
    (mkRoute "z2m" 8080 true)
    (mkRoute "music" 8095 true)
    (mkRoute "jellyfin" 8096 false)
    (mkRoute "sonarr" 8989 true)
    (mkRoute "radarr" 7878 true)
    (mkRoute "lidarr" 8686 true)
    (mkRoute "prowlarr" 9696 true)
    (mkRoute "bazarr" 6767 true)
    (mkRoute "transmission" 9091 true)
    (mkRoute "sabnzbd" 8085 true)
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
