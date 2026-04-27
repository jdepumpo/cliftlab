{
  services.traefik = {
    enable = true;
    staticConfigOptions = {
      entryPoints.web.address = ":80";
      log.level = "INFO";
    };
  };
}
