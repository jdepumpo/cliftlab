{...}: {
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
    environment = {
      OC_INSECURE = "true";
      OC_LOG_LEVEL = "error";
    };
  };
}
