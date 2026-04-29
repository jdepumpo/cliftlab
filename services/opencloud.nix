{config, ...}: {
  sops.templates."opencloud-env" = {
    content = ''
      NOTIFICATIONS_SMTP_PASSWORD=${config.sops.placeholder."authelia-smtp-password"}
    '';
    owner = "opencloud";
  };

  environment.persistence."/nix/persist".directories = [
    {
      directory = "/var/lib/opencloud";
      user = "opencloud";
      group = "opencloud";
      mode = "0750";
    }
    # opencloud-init-config writes opencloud.yaml here on first run (contains admin password)
    {
      directory = "/etc/opencloud";
      user = "root";
      group = "root";
      mode = "0755";
    }
  ];

  services.opencloud = {
    enable = true;
    url = "https://cloud.clift.one";
    environmentFile = config.sops.templates."opencloud-env".path;
    environment = {
      OC_INSECURE = "true";
      OC_LOG_LEVEL = "error";
      OC_SHARING_PUBLIC_SHARE_MUST_HAVE_PASSWORD = "false";
      NOTIFICATIONS_SMTP_HOST = "mail.depumpo.com";
      NOTIFICATIONS_SMTP_PORT = "465";
      NOTIFICATIONS_SMTP_SENDER = "CliftONE Cloud <cloud@jfd.is>";
      NOTIFICATIONS_SMTP_USERNAME = "links@jfd.is";
      NOTIFICATIONS_SMTP_ENCRYPTION = "ssl";
    };
  };
}
