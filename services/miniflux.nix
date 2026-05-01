{config, ...}: {
  sops.secrets."miniflux-admin-credentials" = {};
  sops.secrets."miniflux-oidc-client-secret" = {};

  environment.persistence."/nix/persist".directories = [
    {
      directory = "/var/lib/postgresql";
      user = "postgres";
      group = "postgres";
      mode = "0700";
    }
  ];

  services.miniflux = {
    enable = true;
    createDatabaseLocally = true;
    adminCredentialsFile = config.sops.secrets."miniflux-admin-credentials".path;
    config = {
      LISTEN_ADDR = "127.0.0.1:8083";
      BASE_URL = "https://rss.clift.one";
      OAUTH2_PROVIDER = "oidc";
      OAUTH2_CLIENT_ID = "miniflux";
      OAUTH2_REDIRECT_URL = "https://rss.clift.one/oauth2/oidc/callback";
      OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://auth.clift.one/.well-known/openid-configuration";
      OAUTH2_USER_CREATION = "1";
    };
  };

  sops.templates."miniflux-env" = {
    content = ''
      OAUTH2_CLIENT_SECRET=${config.sops.placeholder."miniflux-oidc-client-secret"}
    '';
  };

  # adminCredentialsFile is already wired as EnvironmentFile by the module;
  # override with a list to also inject the OIDC client secret
  systemd.services.miniflux.serviceConfig.EnvironmentFile = [
    config.sops.secrets."miniflux-admin-credentials".path
    config.sops.templates."miniflux-env".path
  ];
}
