{config, ...}: {
  sops.secrets."cloudflare-api-token" = {};
  sops.templates."traefik-env" = {
    content = ''
      CF_DNS_API_TOKEN=${config.sops.placeholder."cloudflare-api-token"}
    '';
    owner = "traefik";
  };

  networking.firewall.allowedTCPPorts = [80 443];

  environment.persistence."/nix/persist".directories = [
    {
      directory = "/var/lib/traefik";
      user = "traefik";
      group = "traefik";
      mode = "0700";
    }
  ];

  systemd.services.traefik.serviceConfig.EnvironmentFile =
    config.sops.templates."traefik-env".path;

  services.traefik = {
    enable = true;
    staticConfigOptions = {
      entryPoints = {
        web.address = ":80";
        websecure.address = ":443";
      };
      certificatesResolvers.cloudflare.acme = {
        email = "jdepumpo@gmail.com";
        storage = "/var/lib/traefik/acme.json";
        dnsChallenge = {
          provider = "cloudflare";
          resolvers = ["1.1.1.1:53" "1.0.0.1:53"];
        };
      };
      log.level = "INFO";
    };
  };
}
