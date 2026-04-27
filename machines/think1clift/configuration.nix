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

  networking.hostName = "think1clift";
}
