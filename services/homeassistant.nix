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
    # DynamicUser services use /var/lib/private (mode 0700 required by systemd)
    {
      directory = "/var/lib/private";
      mode = "0700";
    }
  ];

  services.home-assistant = {
    enable = true;
    openFirewall = false;
    extraComponents = [
      "analytics"
      "bluetooth"
      "esphome"
      "google_translate"
      "ibeacon"
      "isal"
      "met"
      "mqtt"
      "radio_browser"
      "roku"
      "shopping_list"
    ];
    config = {
      default_config = {};
      http = {
        server_host = "127.0.0.1";
        use_x_forwarded_for = true;
        trusted_proxies = ["127.0.0.1"];
      };
      logger = {
        default = "warning";
        logs."homeassistant.components.mqtt" = "debug";
      };
    };
  };

  services.music-assistant = {
    enable = true;
    providers = ["squeezelite" "spotify" "jellyfin"];
  };

  # SlimProto port for Squeezelite player connections
  networking.firewall.allowedTCPPorts = [3483];
  networking.firewall.allowedUDPPorts = [3483];

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
      Environment = [
        "HOME=/var/lib/isponsorblocktv"
        "iSPBTV_data_dir=/var/lib/isponsorblocktv"
      ];
      Restart = "on-failure";
      RestartSec = "10s";
    };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  users.users.hass.extraGroups = ["bluetooth"];

  # Local-only MQTT broker — open firewall port 1883 if IoT devices on LAN need access
  services.mosquitto = {
    enable = true;
    persistence = true;
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
      homeassistant = {
        enabled = true;
      };
    };
  };
}
