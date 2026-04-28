{config, ...}: {
  sops.secrets."cloudflare-tunnel" = {
    format = "binary";
    sopsFile = ./../secrets/cloudflare-tunnel;
  };

  services.cloudflared = {
    enable = true;
    tunnels."3ef0f677-42ba-441c-8192-72f4d66b6dad" = {
      credentialsFile = config.sops.secrets."cloudflare-tunnel".path;
      ingress."*.clift.one" = "http://localhost:80";
      default = "http_status:404";
    };
  };
}
