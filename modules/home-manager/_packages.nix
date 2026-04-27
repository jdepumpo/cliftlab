{pkgs, ...}: {
  home.packages = with pkgs; [
    alejandra
    croc
    curl
    dig
    dua
    duf
    dust
    gdu
    hyperfine
    imagemagick
    jq
    just
    nil
    openssl
    sops
    statix
    tree
    wget
  ];
}
