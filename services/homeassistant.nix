{...}: {
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
  ];

  services.home-assistant = {
    enable = true;
    openFirewall = false;
    extraComponents = [
      "met"
      "mqtt"
      "radio_browser"
      "esphome"
    ];
    extraPackages = ps: with ps; [numpy];
    config = {
      http = {
        server_host = "127.0.0.1";
        use_x_forwarded_for = true;
        trusted_proxies = ["127.0.0.1"];
      };
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
