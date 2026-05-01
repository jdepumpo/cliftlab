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
    ./../../services/authelia.nix
    ./../../services/homeassistant.nix
    ./../../services/opencloud.nix
    ./../../services/miniflux.nix
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
    };
    defaultGateway = "192.168.0.1";
    defaultGateway6 = {
      address = "";
      interface = "enp0s31f6";
    };
    # Services that self-reference via their public domain need to resolve locally
    hosts."127.0.0.1" = ["cloud.clift.one" "auth.clift.one"];
  };
}
