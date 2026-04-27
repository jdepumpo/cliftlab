{config, ...}: {
  sops.secrets.cloudflare-tunnel = {
    owner = "cloudflared";
    mode = "0400";
  };

  services.cloudflared = {
    enable = true;
    tunnels."3ef0f677-42ba-441c-8192-72f4d66b6dad" = {
      credentialsFile = config.sops.secrets.cloudflare-tunnel.path;
      ingress."*" = "http://localhost:80";
      default = "http_status:404";
    };
  };
}
