{
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
  };

  networking.firewall = {
    trustedInterfaces = ["tailscale0"];
    allowedUDPPorts = [41641];
  };
}
