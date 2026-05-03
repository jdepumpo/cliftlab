{
  inputs,
  outputs,
  vars,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.impermanence.nixosModules.impermanence

    # Generated on first install via: nixos-generate-config --show-hardware-config
    ./hardware-configuration.nix

    ./../../modules/nixos/base.nix
    ./../../modules/nixos/desktop.nix

    ./../../services/tailscale.nix
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs vars;};
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${vars.userName} = {
      imports = [
        ./../../modules/home-manager/base.nix
        ./../../modules/home-manager/desktop.nix
      ];
    };
  };

  networking.hostName = "dell1clift";
}
