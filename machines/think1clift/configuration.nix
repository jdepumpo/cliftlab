{
  inputs,
  outputs,
  vars,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence

    ./hardware-configuration.nix

    ./../../modules/nixos/base.nix
    ./../../modules/nixos/remote-unlock.nix

    ./../../services/tailscale.nix
    ./../../services/traefik.nix
    ./../../services/cloudflared.nix
    ./../../services/nixarr.nix
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs vars;};
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${vars.userName} = {
      imports = [
        ./../../modules/home-manager/base.nix
      ];
    };
  };

  networking = {
    hostName = "think1clift";
    interfaces.enp0s31f6 = {
      ipv4.addresses = [{
        address = "192.168.0.204";
        prefixLength = 24;
      }];
      # IPv6 via SLAAC (router advertisement) — no static address needed
      ipv6.addresses = [];
    };
    defaultGateway = "192.168.0.1";
    defaultGateway6 = {
      address = "";
      interface = "enp0s31f6";
    };
  };
}
