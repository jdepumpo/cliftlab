{vars, ...}: {
  imports = [
    ./_packages.nix
    ./_zsh.nix
  ];

  home = {
    username = vars.userName;
    homeDirectory = "/home/${vars.userName}";
    stateVersion = "23.11";
  };

  programs = {
    helix = {
      enable = true;
      defaultEditor = true;
      settings = {
        theme = "dark_high_contrast";
      };
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    zellij = {
      enable = true;
      settings = {
        theme = "dracula";
      };
    };
    tealdeer = {
      enable = true;
      settings.updates.auto_update = true;
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    bat.enable = true;
    btop.enable = true;
    gallery-dl.enable = true;
    fastfetch.enable = true;
    htop.enable = true;
    lsd.enable = true;
    nh.enable = true;
    vim.enable = true;
    yt-dlp.enable = true;
    ripgrep.enable = true;
    fd.enable = true;
  };

  systemd.user.startServices = "sd-switch";
}
