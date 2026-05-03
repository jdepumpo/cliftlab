{pkgs, ...}: {
  home.packages = with pkgs; [
    firefox
    # Productivity
    libreoffice-qt6-fresh
    # Media
    vlc
    # Utilities
    wl-clipboard
    xdg-utils
  ];
}
