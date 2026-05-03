{
  pkgs,
  vars,
  ...
}: {
  # Display manager + desktop environment
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;

  # Networking via NetworkManager (WiFi, wired DHCP)
  networking = {
    useDHCP = false; # NetworkManager handles DHCP per-interface
    networkmanager.enable = true;
  };

  # Intel Iris Xe GPU + hardware video acceleration
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-compute-runtime
    ];
  };

  # Audio via PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Power management (intel-specific thermal daemon + power profiles)
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;

  # Laptop lid/suspend behavior
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchExternalPower = "lock";
  };

  # Add user to desktop-relevant groups
  users.users.${vars.userName}.extraGroups = ["networkmanager" "video" "audio"];

  # Persist WiFi connections and user home across reboots
  environment.persistence."/nix/persist" = {
    directories = [
      "/etc/NetworkManager/system-connections"
    ];
    users.${vars.userName} = {
      directories = [
        "Desktop"
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Videos"
        "git"
        ".cache"
        ".config"
        ".local"
        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }
      ];
      files = [".zsh_history"];
    };
  };
}
