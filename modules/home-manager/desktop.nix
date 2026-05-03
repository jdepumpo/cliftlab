{pkgs, ...}: {
  home.packages = with pkgs; [
    firefox
    bitwarden-desktop
    # Productivity
    libreoffice-qt6-fresh
    # Media
    vlc
    # Utilities
    wl-clipboard
    xdg-utils
  ];

  # Point SSH_AUTH_SOCK at Bitwarden's SSH agent socket.
  # The fallback ssh-agent in _zsh.nix only fires when this is unset,
  # so it won't conflict as long as Bitwarden is running.
  home.sessionVariables = {
    SSH_AUTH_SOCK = "$HOME/.bitwarden-ssh-agent.sock";
  };
}
