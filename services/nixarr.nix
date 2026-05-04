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
  sops.secrets."sonarr-api-key" = {};
  sops.secrets."radarr-api-key" = {};

  sops.templates."recyclarr.yml" = {
    owner = "recyclarr";
    content = ''
      sonarr:
        main:
          base_url: http://localhost:8989
          api_key: ${config.sops.placeholder."sonarr-api-key"}
          include:
            - template: sonarr-quality-definition-series
            - template: sonarr-v4-quality-profile-web-1080p
            - template: sonarr-v4-custom-formats-web-1080p
          media_naming:
            series: plex
            season: default
            episodes:
              rename: true
              standard: default
              daily: default
              anime: default

      radarr:
        main:
          base_url: http://localhost:7878
          api_key: ${config.sops.placeholder."radarr-api-key"}
          include:
            - template: radarr-quality-definition-movie
            - template: radarr-quality-profile-web-1080p
            - template: radarr-custom-formats-web-1080p
          media_naming:
            movie:
              rename: true
              standard: default
    '';
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
      guiPort = 6336;
      whitelistHostnames = ["sabnzbd.clift.one"];
    };

    recyclarr = {
      enable = true;
      configFile = config.sops.templates."recyclarr.yml".path;
    };
  };

  # nixarr doesn't expose rpc-host-whitelist; set it directly so Traefik's
  # Host header (transmission.clift.one) isn't rejected by the RPC server.
  services.transmission.settings = {
    "rpc-host-whitelist-enabled" = true;
    "rpc-host-whitelist" = "transmission.clift.one";
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
    (mkRoute "sabnzbd" 6336 true)
    (mkRoute "rss" 8083 false)
  ];

  # TRaSH-recommended media library dirs — siblings of usenet/ and torrents/ so
  # hardlinks work across download clients and library (all same filesystem).
  # nixarr manages usenet/ and torrents/ automatically; these are the library roots.
  systemd.tmpfiles.rules = let
    mediaDir = "/nix/persist/media";
    mkMediaDir = path: "d ${mediaDir}/${path} 0775 root media -";
  in [
    (mkMediaDir "movies")
    (mkMediaDir "tv")
    (mkMediaDir "music")
    (mkMediaDir "books")
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
