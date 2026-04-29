{pkgs, ...}: {
  environment.persistence."/nix/persist".directories = [
    {
      directory = "/var/lib/hass";
      user = "hass";
      group = "hass";
      mode = "0700";
    }
    {
      directory = "/var/lib/mosquitto";
      user = "mosquitto";
      group = "mosquitto";
      mode = "0750";
    }
    {
      directory = "/var/lib/zigbee2mqtt";
      user = "zigbee2mqtt";
      group = "zigbee2mqtt";
      mode = "0700";
    }
    # DynamicUser services use /var/lib/private/* — systemd symlinks /var/lib/<name> there
    "/var/lib/private/music-assistant"
    "/var/lib/private/isponsorblocktv"
  ];

  services.home-assistant = {
    enable = true;
    openFirewall = false;
    extraComponents = [
      "analytics"
      "google_translate"
      "isal"
      "met"
      "mqtt"
      "radio_browser"
      "shopping_list"
      "esphome"
    ];
    config = {
      default_config = {};
      http = {
        server_host = "127.0.0.1";
        use_x_forwarded_for = true;
        trusted_proxies = ["127.0.0.1"];
      };
    };
  };

  services.music-assistant.enable = true;

  # iSponsorBlockTV has no NixOS module — run as a minimal systemd service
  # Config lives at /var/lib/isponsorblocktv/config.json; set it up manually then start the service
  systemd.services.isponsorblocktv = {
    description = "iSponsorBlockTV";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${pkgs.isponsorblocktv}/bin/iSponsorBlockTV";
      DynamicUser = true;
      StateDirectory = "isponsorblocktv";
      WorkingDirectory = "/var/lib/isponsorblocktv";
      Environment = "HOME=/var/lib/isponsorblocktv";
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };

  # Local-only MQTT broker — open firewall port 1883 if IoT devices on LAN need access
  services.mosquitto = {
    enable = true;
    listeners = [
      {
        address = "127.0.0.1";
        port = 1883;
        settings.allow_anonymous = true;
      }
    ];
  };

  services.zigbee2mqtt = {
    enable = true;
    settings = {
      permit_join = false;
      mqtt.server = "mqtt://localhost:1883";
      serial = {
        port = "/dev/serial/by-id/usb-1a86_USB_Serial-if00-port0";
        adapter = "ember";
      };
      frontend = {
        port = 8080;
        host = "127.0.0.1";
      };
    };
  };
}
