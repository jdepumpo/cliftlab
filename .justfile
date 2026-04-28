default:
    just --list

deploy machine='' ip='':
    @if [ -z "{{ machine }}" ] && [ -z "{{ ip }}" ]; then \
      sudo nixos-rebuild switch --flake .; \
    elif [ -z "{{ ip }}" ]; then \
      sudo nixos-rebuild switch --flake ".#{{ machine }}"; \
    else \
      nixos-rebuild switch --fast --flake ".#{{ machine }}" --sudo --target-host "joseph@{{ ip }}" --build-host "joseph@{{ ip }}"; \
    fi

up:
    nix flake update

lint:
    statix check .

fmt:
    nix fmt .

clean:
    sudo nix-collect-garbage -d && nix-collect-garbage -d

repair:
    sudo nix-store --verify --check-contents --repair

sops-edit:
    sops secrets/secrets.yaml

sops-rotate:
    for file in secrets/*; do sops --rotate --in-place "$file"; done

sops-update:
    for file in secrets/*; do sops updatekeys "$file"; done

build-iso:
    nix build .#nixosConfigurations.iso1clift.config.system.build.isoImage

deploy-remote machine='' ip='':
    nix run nixpkgs#nixos-rebuild -- switch --fast --flake ".#{{ machine }}" --sudo --target-host "joseph@{{ ip }}" --build-host "joseph@{{ ip }}"
